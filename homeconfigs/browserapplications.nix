{ pkgs, ... }:
{
  xdg.desktopEntries = {
    notion = {
      name = "Notion";
      genericName = "Workspace";
      comment = "Notion web app";
      exec = "firefox --new-window https://www.notion.so";
      terminal = false;
      categories = [ "Office" "Utility" ];
      icon = ../icons/notion.png;
    };

    outlook = {
      name = "Outlook";
      genericName = "Mail";
      comment = "Outlook web app";
      exec = "firefox --new-window outlook.office.com";
      terminal = false;
      categories = [ "Office" "Email" ];
      icon = ../icons/Outlook.png;
    };
    chatgpt = {
      name = "ChatGPT";
      genericName = "AI Assistant";
      comment = "ChatGPT web app";
      # swap 'chromium' for brave/google-chrome/ungoogled-chromium if you prefer
      exec = "firefox --new-window https://chat.openai.com/";
      terminal = false;
      categories = [ "Network" "Utility" ];
      icon = ../icons/chatGPT.png;

    };
    claude = {
      name = "Claude";
      genericName = "AI Assistant";
      comment = "Claude web app";
      exec = "firefox --new-window https://claude.ai/";
      terminal = false;
      categories = [ "Network" "Utility" ];
      icon = ../icons/Claude.png;
    };
  };
}
