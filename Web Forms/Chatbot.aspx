<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Chatbot.aspx.cs" Inherits="Chatbot" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
  <title>Chatbot</title>
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet" />
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://cdn.tailwindcss.com?plugins=forms,typography,aspect-ratio,container-queries"></script>
  <script defer="defer" src="https://unpkg.com/alpinejs"></script>
  <script defer="defer" src="https://unpkg.com/@material-tailwind/html@latest/scripts/ripple.js"></script>
  <style type="text/tailwindcss">
    .sidebar {
      @apply max-w-48 md:max-w-56 xl:max-w-64 px-2 xl:px-4 pt-4 pb-2 space-y-1 overflow-y-auto
    }

    .textbox {
      @apply w-full -ml-[100%] px-1.5 py-2 resize-none overflow-y-auto bg-gray-100 border-0 !ring-0 break-words text-gray-600 placeholder:text-transparent sm:placeholder-gray-600 sm:focus:placeholder-gray-400;
    }

    .resizer {
      @apply w-full px-1.5 py-2 overflow-y-auto rounded-[27px] break-words invisible;
    }

    .textbox, .resizer {
      scrollbar-gutter: stable both-edges;
    }

      .textbox::-webkit-scrollbar, .resizer::-webkit-scrollbar {
        width: .375rem;
      }

      .textbox::-webkit-scrollbar-thumb {
        background-color: lightgray;
        border-radius: 27px;
      }

        .textbox::-webkit-scrollbar-thumb:hover {
          background-color: gray;
        }

    .sidebar::-webkit-scrollbar {
      width: .5rem;
    }

    .sidebar::-webkit-scrollbar-thumb {
      background-color: gray;
      border-radius: 27px;
    }
  </style>
</head>

<body>
  <form id="form" runat="server" class="m-0">
    <!-- Layout -->
    <div class="flex h-dvh overflow-y-hidden">
      <!-- Sidebar -->
      <div class="flex flex-col w-1/5 min-w-fit max-w-64 h-dvh border-e bg-white font-sans antialiased">
        <div class="flex flex-col px-4 py-6">
          <!-- New Chat Button -->
          <button id="NewChatBtn" runat="server" onserverclick="NewChat"
            class="group relative inline-block rounded-full focus:outline-none focus:ring">
            <span
              class="absolute inset-0 translate-x-0 translate-y-0 bg-yellow-300 rounded-full transition-transform group-hover:translate-x-1.5 group-hover:translate-y-1.5"></span>
            <span
              class="relative inline-block w-full px-8 py-3 rounded-full border-2 border-current text-center text-sm font-bold uppercase tracking-widest">New Chat
            </span>
          </button>
        </div>

        <div class="flex flex-col flex-auto overflow-hidden">
          <span class="relative flex justify-center">
            <span class="absolute inset-x-0 top-1/2 h-px -translate-y-1/2 bg-transparent bg-gradient-to-r from-transparent via-gray-500 to-transparent opacity-75"></span>
            <span class="relative px-3 z-10 bg-white text-xs font-bold uppercase italic tracking-tight">Chats...</span>
          </span>

          <!-- Sidebar Chat List -->
          <ul id="SidebarList" runat="server" class="sidebar"></ul>

        </div>

        <div class="flex flex-col">
          <a href="#" class="flex items-center px-4 py-[22px] gap-2 bg-white border-t border-gray-100 hover:bg-gray-50"
            data-ripple-light="true">
            <img runat="server" src="~/Assets/Lucky.jpg" class="size-10 rounded-full object-cover" />
            <div>
              <p class="text-xs">
                <strong class="block font-medium">Lucky</strong>
                <span>github.com/luckycatx</span>
              </p>
            </div>
          </a>
        </div>
      </div>

      <!-- Main Content -->
      <div class="flex flex-col flex-auto min-w-64 overflow-auto">
        <!-- Header -->
        <header class="min-w-fit bg-gray-50">
          <div class="max-w-screen-xl mx-auto px-4 md:px-6 lg:px-8 py-4">
            <div class="flex items-center justify-between">
              <div class="text-center md:text-left">
                <h1 class="text-2xl md:text-3xl font-bold text-gray-900">CAT BOT</h1>
                <p class="mt-1.5 text-sm text-gray-500 italic">Let's start chatting! 🎉</p>
              </div>

              <div class="flex">
                <span
                  class="material-symbols-outlined text-[36px] md:text-[48px] relative inline-block p-1.5 object-cover object-center rounded-full border-2 border-gray-700">
                  ar_stickers
                </span>
              </div>

            </div>
          </div>
        </header>

        <!-- Chat Window -->
        <div class="flex flex-col flex-auto px-[5%] py-8 overflow-y-auto">
          <!-- LOGO -->
          <div id="Logo" runat="server" class="m-auto pb-6 pr-12 lg:pr-16 xl:pr-20 text-center max-sm:hidden">
          <a href="https://github.com/luckycatx" class="hover:opacity-50">
            <div class="flex items-center justify-center mx-auto text-center max-w-7xl"
                 x-data="{ text: '', textArray : ['CAT BOT', 'Start Chatting!', 'MEOW~'],
                        textIndex: 0, charIndex: 0, typeSpeed: 117, cursorSpeed: 570,
                        pauseEnd: 1570, pauseStart: 17, direction: 'forward' }"
                 x-init="
                        $nextTick(() => {
                          let typingInterval = setInterval(startTyping, $data.typeSpeed);

                          function startTyping() {
                            let current = $data.textArray[$data.textIndex];
                            if ($data.charIndex > current.length) {
                              $data.direction = 'backward';
                              clearInterval(typingInterval);
                              setTimeout(() => {
                                typingInterval = setInterval(startTyping, $data.typeSpeed);
                              }, $data.pauseEnd);
                            }
                            $data.text = current.substring(0, $data.charIndex);
                            if ($data.direction == 'forward') {
                              $data.charIndex += 1;
                            } else {
                              if ($data.charIndex == 0) {
                                $data.direction = 'forward';
                                clearInterval(typingInterval);
                                setTimeout(() => {
                                  $data.textIndex += 1;
                                  if ($data.textIndex >= $data.textArray.length) $data.textIndex = 0;
                                  typingInterval = setInterval(startTyping, $data.typeSpeed);
                                }, $data.pauseStart);
                              }
                              $data.charIndex -= 1;
                            }
                          }

                          setInterval(() => {
                            if ($refs.cursor.classList.contains('hidden'))
                              $refs.cursor.classList.remove('hidden');
                            else
                              $refs.cursor.classList.add('hidden');
                          }, $data.cursorSpeed);

                        })">
              <div class="relative flex items-center justify-center h-auto">
                <p class="text-6xl lg:text-7xl xl:text-8xl font-black leading-tight" x-text="text"></p>
                <span class="absolute right-0 w-2 -mr-2 bg-black h-3/4" x-ref="cursor"></span>
              </div>
            </div>
          </a>
        </div>

          <!-- Message Area -->
          <div id="MessageArea" runat="server" class="pr-[2%]"></div>

        </div>

        <!-- Input Field -->
        <div class="flex justify-center max-h-[27.5%] px-4 pt-4 pb-6 border-t-2 border-gray-200">
          <!-- Input Wrapper -->
          <div
            class="flex items-end w-3/4 bg-gray-100 rounded-[27px] border-2 border-gray-200 focus-within:border-gray-900">
            <!-- Icon -->
            <div class="flex pl-4 pb-2">
              <span class="material-symbols-outlined text-[22px]">edit_square</span>
            </div>
            <!-- Textbox Wrapper -->
            <div class="flex flex-auto max-h-full overflow-hidden">
              <!-- Invisible div for auto resize -->
              <div class="resizer"></div>
              <asp:TextBox ID="MessageBox" runat="server" TextMode="MultiLine" Rows="1"
                CssClass="textbox" placeholder="Type a message..."
                oninput="this.previousElementSibling.innerText = this.value + String.fromCharCode(10)"></asp:TextBox>
            </div>
            <!-- Send Button -->
            <div class="flex px-3 pb-1">
              <button id="SendBtn" runat="server" type="button" onserverclick="SendMessage"
                class="inline-flex items-center justify-center w-8 h-8 bg-gray-700 rounded-full text-white transition duration-200 ease-in-out hover:bg-gray-900 focus:outline-none"
                data-ripple-light="true">
                <span class="material-symbols-outlined text-[20px]">send</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </form>
  <script>
    // Check for empty message box
    const SendCheck = () => {
      const MessageBox = document.getElementById("MessageBox");
      const SendBtn = document.getElementById("SendBtn");
      if (MessageBox.value.trim() === "") {
        SendBtn.classList.remove("bg-gray-700");
        SendBtn.classList.remove("hover:bg-gray-900");
        SendBtn.classList.add("bg-gray-300");
        SendBtn.disabled = true;
      } else {
        SendBtn.classList.remove("bg-gray-300");
        SendBtn.classList.add("hover:bg-gray-900");
        SendBtn.classList.add("bg-gray-700");
        SendBtn.disabled = false;
      }
    };
    MessageBox.addEventListener("input", SendCheck);
    SendCheck();

    // Allow enter key to send message
    MessageBox.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        document.getElementById("SendBtn").click();
      }
    });
  </script>
</body>

</html>
