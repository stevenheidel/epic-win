module EpicWin
  
  require 'Win32API'
  require 'yaml'

  # Load the functions
  YAML.load_file('functions.yml').each do |name, put|
    input, output = put.split 
    input = [] if input == "X"
    output = [] if output == "X"
    eval("#{name} = Win32API.new('user32', '#{name}', '#{input}', '#{output}')")
  end

  # Load the constants
  YAML.load_file('constants.yml').each do |name, value|
    eval("#{name} = #{value}")
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

    def send_command(wparam, lparam = 0)
      SendMessage.call(@hwnd, WM_COMMAND, wparam, lparam)
    end

    private

    def find_window_like(regexp)
      hwnd = GetTopWindow.call(GetDesktopWindow.call)
      
      until get_title(hwnd) =~ regexp
        if (hwnd = GetWindow.call(hwnd, GW_HWNDNEXT)) == 0
          raise "Window matching #{regexp} could not be found"
        end
      end
      
      hwnd
    end
    
    def find_window_starting_with(string)
      hwnd = GetTopWindow.call(GetDesktopWindow.call)
      
      until get_title(hwnd)[0,string.length] == string
        if (hwnd = GetWindow.call(hwnd, GW_HWNDNEXT)) == 0
          raise "Window starting with #{string} could not be found"
        end
      end
      
      hwnd
    end
    
    def get_title(hwnd, max_length = 256)
      title_buffer = ' ' * max_length
      GetWindowText.call(hwnd, title_buffer, max_length)
      title_buffer.rstrip.chop
    end
    
  end
  
end

