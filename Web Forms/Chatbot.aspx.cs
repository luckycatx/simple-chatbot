using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Chatbot : Page {
  private const int MaxChat = 16;
  private const int MaxMsg = 256;

  protected void Page_Load(object sender, EventArgs e) {
    if (IsPostBack) {
      // Render here for adding click event
      RenderSideBar();
      return;
    }
    Session["refresh"] = Guid.NewGuid().ToString();
    ViewState["chatting"] = false;

    string avatar_path = "~/Assets/lucky.jpg";
    string bot_path = MapPath("~/Assets/bot.json");
    Session["chat_session"] = new ChatSession(MaxChat, avatar_path, bot_path);
  }

  protected void Page_PreRender(object sender, EventArgs e) {
    MessageBox.Text = string.Empty;
    // Set the refresh state of the current page
    ViewState["refresh"] = Session["refresh"];
    // Determine logo rendering
    ChatLogo(ViewState["chatting"] is bool x && x);
  }

  protected void SendMessage(object sender, EventArgs e) {
    var cs = Session["chat_session"] as ChatSession;

    // Handle refresh
    if (Refreshed()) {
      RenderMessage(cs);
      return;
    }
    ViewState["chatting"] = true;

    int idx = cs.Index;

    // Get user input message
    List<string> user_chat = cs.Chats[idx];
    if (user_chat.Count == 0) {
      cs.ChatCount++;
    } else if (user_chat.Count == MaxMsg) {
      Response.Write("<script>alert('You\\'ve reached the maximum message limit');</script>");
      return;
    }
    string user_msg = MessageBox.Text;
    user_chat.Add(user_msg);

    // Get ReplyBot response message
    List<string> bot_chat = cs.Chats[idx + MaxChat];
    string bot_msg = cs.ReplyBot.Reply(Regex.Replace(user_msg, @"[\p{P}\p{S}]+$", string.Empty));
    bot_chat.Add(bot_msg);

    PlaceSideBar(cs);
    RenderMessage(cs);
  }

  protected void RenderMessage(ChatSession cs) {
    int idx = cs.Index;
    List<string> user_chat = cs.Chats[idx];
    List<string> bot_chat = cs.Chats[idx + MaxChat];
    if (user_chat.Count == 0)
      return;
    else
      ViewState["chatting"] = true;

    for (int i = 0; i < user_chat.Count; i++) {
      string msg_id = "msg_" + i;
      var user_msg_wrapper = ParseControl(cs.UserMessageHTML(msg_id));
      MessageArea.Controls.Add(user_msg_wrapper);
      (FindControl(msg_id) as Label).Text = user_chat[i];

      var bot_msg_wrapper = ParseControl(cs.BotMessageHTML(bot_chat[i]));
      MessageArea.Controls.Add(bot_msg_wrapper);
    }
  }

  protected void NewChat(object sender, EventArgs e) {
    // Handle refresh
    if (Refreshed()) return;

    var cs = Session["chat_session"] as ChatSession;
    if (cs.ChatCount == MaxChat) {
      Response.Write("<script>alert('You\\'ve reached the maximum chat limit');</script>");
      return;
    }
    ViewState["chatting"] = false;
    cs.Index = cs.Chats[cs.ChatCount].Count == 0 ? cs.ChatCount : ++cs.ChatCount;
  }

  protected void SwitchChat(object sender, EventArgs e) {
    // Handle refresh
    if (Refreshed()) return;

    var side = sender as Button;
    var cs = Session["chat_session"] as ChatSession;
    cs.Index = side.ClientID[side.ClientID.Length - 1] - '0';
    ViewState["chatting"] = true;

    RenderMessage(cs);
  }

  protected void PlaceSideBar(ChatSession cs) {
    int idx = cs.Index;
    // Skip initiated
    if (cs.SideBar[idx]) return;
    cs.SideBar[idx] = true;
    var bar = ParseControl(cs.SidebarItemHTML("side_" + idx, cs.Chats[idx][0]));
    SidebarList.Controls.Add(bar);
  }

  protected void RenderSideBar() {
    var cs = Session["chat_session"] as ChatSession;
    // Render from the user chats
    for (int i = 0; i < cs.ChatCount; i++) {
      // Skip if the bar that is not initiated
      if (!cs.SideBar[i]) continue;
      SidebarList.Controls.Add(ParseControl(cs.SidebarItemHTML("side_" + i, cs.Chats[i][0])));
      var bar = FindControl("side_" + i) as Button;
      bar.Command += SwitchChat;
    }
  }
  public void ChatLogo(bool yes) {
    Logo.Visible = !yes;
  }

  public bool Refreshed() {
    if (ViewState["refresh"].ToString() != Session["refresh"].ToString()) {
      return true;
    } else {
      Session["refresh"] = Guid.NewGuid().ToString();
      return false;
    }
  }
}

public class ChatSession {
  private int index;
  public int Index { get => index; set { if (value >= 0 && value < Chats.Length / 2) index = value; } }
  public List<string>[] Chats { get; set; }
  public int ChatCount { get; set; }
  public bool[] SideBar;
  public string AvatarPath { get; set; }
  public Bot ReplyBot { get; }

  public ChatSession(int max_chats, string avatar_path, string bot_path) {
    index = 0;
    Chats = Enumerable.Range(0, max_chats * 2).Select(_ => new List<string>()).ToArray();
    ChatCount = 0;
    SideBar = new bool[max_chats];
    AvatarPath = avatar_path;
    ReplyBot = new Bot(bot_path);
  }

  public string UserMessageHTML(string msg_id) {
    return
    @"
    <div class=""flex items-start justify-end pb-2 gap-2.5"">
      <div class=""flex flex-col max-w-[75%] gap-1"">
        <div class=""flex items-center justify-end space-x-2"">
          <span class=""text-sm text-gray-500 font-normal dark:text-gray-400"">time</span>
          <span class=""text-sm text-gray-900 font-semibold dark:text-white"">You</span>
        </div>
        <div class=""flex flex-col self-end w-fit max-w-full px-4 py-3 border-gray-200 bg-gray-100 rounded-2xl rounded-tr leading-1.5 dark:bg-gray-700"">"
  + string.Format(@"
          <asp:Label ID=""{0}"" runat=""server"" Text=""..."" CssClass=""break-words text-sm text-gray-900 font-normal dark:text-white""></asp:Label>", msg_id)
  + @"
        </div>
        <span class=""pr-1 text-xs text-gray-500 text-end font-normal dark:text-gray-400"">Sent</span>
      </div>"
  + string.Format(@"
      <img runat=""server"" src=""{0}"" class=""size-8 rounded-full object-cover"" />
    </div>", AvatarPath);
  }

  public string BotMessageHTML(string msg) {
    return string.Format(
    @"
    <div class=""flex items-start pb-2 gap-2.5"">
      <span class=""material-symbols-outlined text-[32px]"">family_star</span>
      <div class=""flex flex-col max-w-[75%] gap-1"">
        <div class=""flex items-center space-x-2"">
          <span class=""text-sm text-gray-900 font-semibold dark:text-white"">Bot</span>
          <span class=""text-sm text-gray-500 font-normal dark:text-gray-400"">time</span>
        </div>
        <div
          class=""flex flex-col w-fit max-w-full px-4 py-3 border-gray-200 bg-gray-100 rounded-2xl rounded-tl leading-1.5 dark:bg-gray-700"">
          <p class=""break-words text-sm text-gray-900 font-normal dark:text-white"">
            {0}
          </p>
        </div>
        <span class=""pl-1 text-xs text-gray-500 font-normal dark:text-gray-400"">Sent</span>
      </div>
    </div>", msg);
  }

  public string SidebarItemHTML(string idx, string msg) {
    return string.Format(
    @"
    <li><asp:Button ID=""{0}"" runat=""server"" Text=""{1}""
        CssClass=""w-full rounded-lg bg-gray-100 px-4 py-2 text-start text-sm text-gray-700 font-medium truncate cursor-pointer"" />
    </li>", idx, msg);
  }
}

public class Bot {
  private readonly Dictionary<string, List<string>> responses;
  private readonly Random reply;

  public Bot(string resp_file) {
    string resp_json = File.ReadAllText(resp_file);
    responses = JsonSerializer.Deserialize<Dictionary<string, List<string>>>(resp_json);
    reply = new Random();
  }

  public string Reply(string msg) {
    msg = msg.ToLower();
    if (responses.ContainsKey(msg)) {
      List<string> replies = responses[msg];
      return replies[reply.Next(replies.Count)];
    }
    var idk = new List<string>() { "I don't know", "I'm not sure how to respond to that", "I can't help with that" };
    return idk[reply.Next(idk.Count)];
  }
}