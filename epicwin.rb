module EpicWin
  
  require 'Win32API'
  
  BM_CLICK = 0x00F5
  
  GW_HWNDNEXT = 2
  
  SW_SHOWNORMAL = 1
  SW_SHOWMINIMIZED = 2
  SW_SHOWMAXIMIZED = 3
  
  WM_KEYDOWN = 0x0100
  WM_KEYUP = 0x0101
  WM_CHAR = 0x0102
  WM_COMMAND = 0x111
  
  win32functions = [] \
  << %w(FindWindow PP L) \
  << %w(ShowWindow IP I) \
  << %w(SetForegroundWindow I L) \
  << %w(FindWindowEx PPPP P) \
  << %w(SendMessage IPII I) \
  << %w(PostMessage IPII I) \
  << %w(GetWindow II I) \
  << %w(GetWindowText LPI I) \
  << %w(GetWindowTextLength I I) \
  << %w(GetTopWindow I I) \
  << %w(GetDesktopWindow []  I) \
  << %w(ShowOwnedPopups II I) \
  << %w(AnyPopup []  I) \
  << %w(GetLastActivePopup I I)
  
  win32functions.each do |name, input, output|
    eval("#{name} = Win32API.new('user32', '#{name}', '#{input}', '#{output}')")
  end
  
  class Window
    
    attr_accessor :title, :hwnd
    
    def initialize(title)
      if title.class == Regexp
        @hwnd = find_window_like(title)
      else
        @hwnd = find_window_starting_with(title)
      end
      
      @title = get_title(@hwnd)
    end
    
    def self.find_window_like(regexp)
      hwnd = GetTopWindow.call(GetDesktopWindow.call)
      
      until get_title(hwnd) =~ regexp
        if (hwnd = GetWindow.call(hwnd, GW_HWNDNEXT)) == 0
          raise "Window matching #{regexp} could not be found"
        end
      end
      
      hwnd
    end
    
    def self.find_window_starting_with(string)
      hwnd = GetTopWindow.call(GetDesktopWindow.call)
      
      until get_title(hwnd)[0,string.length] == string
        if (hwnd = GetWindow.call(hwnd, GW_HWNDNEXT)) == 0
          raise "Window starting with #{string} could not be found"
        end
      end
      
      hwnd
    end
    
    def self.get_title(hwnd, max_length = 256)
      title_buffer = ' ' * max_length
      GetWindowText.call(hwnd, title_buffer, max_length)
      title_buffer.rstrip.chop
    end
    
    def bring_to_front
      SetForegroundWindow.call(@hwnd)
    end
    
    def normalize
      ShowWindow.call(@hwnd, SW_SHOWNORMAL)
    end
    
    def maximize
      ShowWindow.call(@hwnd, SW_SHOWMAXIMIZED)
    end
    
    def minimize
      ShowWindow.call(@hwnd, SW_SHOWMINIMIZED)
    end
    
    def post_message(message, wparam, lparam)
      PostMessage.call(@hwnd, message, wparam, lparam)
    end
    
    def send_message(message, wparam, lparam)
      SendMessage.call(@hwnd, message, wparam, lparam)
    end
    
    def post_command(wparam, lparam = 0)
      PostMessage.call(@hwnd, WM_COMMAND, wparam, lparam)
    end
    
  end
  
end
