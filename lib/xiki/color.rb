require 'xiki/effects'
require 'xiki/styles'

# Colors lines, and shows only colored lines
class Color

  def self.menu
    %`
    - .mark/
      - .next/
      - .previous/
      - .outline/
      - .show/
      - light/
      - red/
      - orange/
      - yellow/
      - green/
      - blue/
      - purple/
      - white/
      - .delete/
      - .clear/
    - docs/
      - overview/
        | Temporarily marks lines as red or green etc. as a way to make
        | them visually stand out.  This menu is primarily accessed via this
        | key shortcut:
        |
        |   layout+mark
        |
        | (Control-l Control-m).  Try layout+mark+red on this line, for example.
        | If you type it quickly the menu won't appear.
      - keys/
        @memorize/
          | mark line light gray : layout+mark+light
          | mark line green : layout+mark+green
          | mark line red : layout+mark+red
          | remove next color (except light) : layout+mark+delete
          | remove all color (except light) : layout+mark+kill
          | go to next color : layout+mark+next
          | go to previous color : layout+mark+previous
          | iterate through marked lines : 8+Tab
    - api/
      > Make current line be red, yellow, or blue
      @Color.mark "red"
      @Color.mark "yellow"
      @Color.mark "green"
    - see/
      <@ themes/
      <@ styles/
      <@ effects/
    `
  end

  @@colors = {
    "r"=>:color_rb_red, "y"=>:color_rb_yellow,
    "t"=>:color_rb_orange,
    "e"=>:color_rb_green, "b"=>:color_rb_blue, "u"=>:color_rb_purple,
    "l"=>:color_rb_light,
    "w"=>:color_rb_white,
  }

  @@colors_by_name = {
    "light"=>:color_rb_light,
    "red"=>:color_rb_red,
    "orange"=>:color_rb_orange,
    "yellow"=>:color_rb_yellow,
    "green"=>:color_rb_green, "blue"=>:color_rb_blue, "purple"=>:color_rb_purple,
    "white"=>:color_rb_white,
  }

  def self.mark color

    # /mark/, so show options...

    View.kill if View.name == "@color/mark/"

    # Back in the original view...

    if color == "light"
      # We want there to be only one "light" line per file, so delete existing
      overlays = $el.overlays_in(View.top, View.bottom)   # Get all overlays
      overlays.to_a.reverse.each do |o|   # Loop through and copy all
        if $el.overlay_get(o, :face).to_s == "color-rb-light"
          $el.delete_overlay(o)
        end
      end
    end


    left, right = Line.left, Line.right+1
    over = $el.make_overlay(left, right)
    $el.overlay_put over, :face, @@colors_by_name[color]

    # Save time it was added
    $el.overlay_put over, :created_at, Time.now.to_f.to_s

    nil
  end

  def self.next
    View.kill if View.name == "@color/mark/"
    pos = nil
    Keys.prefix_times do
      pos = $el.next_overlay_change(View.cursor)
      pos = $el.next_overlay_change(pos) unless $el.overlays_at(pos)
      View.to(pos)
    end
    pos != View.bottom
  end

  def self.previous
    View.kill if View.name == "@color/mark/"
    Keys.prefix_times do
      pos = $el.previous_overlay_change(View.cursor)
      pos = $el.previous_overlay_change(pos-2) if $el.overlays_at(pos-2)
      View.to pos
    end
  end

  def self.clear_light

    # We want there to be only one "light" line per file, so delete existing
    overlays = $el.overlays_in(View.top, View.bottom)   # Get all overlays
    overlays.to_a.reverse.each do |o|   # Loop through and copy all
      if $el.overlay_get(o, :face).to_s == "color-rb-light"
        $el.delete_overlay(o)
      end
    end

  end

  def self.delete
    View.kill if View.name == "@color/mark/"

    overlays = $el.overlays_at($el.next_overlay_change($el.point_at_bol - 1))
    return View.beep "- No highlights after cursor!" if ! overlays
    return $el.delete_overlay(overlays[0])
  end

  def self.clear
    View.kill if View.name == "@color/mark/"

    if Keys.prefix_u   # Don't delete map mark
      return $el.remove_overlays
    end

    overlays = $el.overlays_in(View.top, View.bottom)   # Get all overlays
    overlays.to_a.reverse.each do |o|   # Loop through and copy all
      if $el.overlay_get(o, :face).to_s != "color-rb-light"
        $el.delete_overlay(o)
      end
    end

    nil
  end


  #   def self.alternating
  #     orig = View.cursor
  #     # Get region to cover
  #     txt, left, right = View.txt_per_prefix
  #     View.cursor = left
  #     while(View.cursor < right)
  #       Color.colorize_line :color_rb_light
  #       Line.next 2
  #     end
  #     View.cursor = orig
  #   end

  def self.define_styles   # For Keys.layout_kolor_light, etc.

    return if ! $el

    if Styles.dark_bg?

      Styles.define :color_rb_red, :bg => "500"
      Styles.define :color_rb_orange, :bg => "442500"
      Styles.define :color_rb_yellow, :bg => "440"
      Styles.define :color_rb_green, :bg => "131"
      Styles.define :color_rb_white, :fg=>'222', :bg=>'fff', :border=>['fff', -1]
      Styles.define :color_rb_light, :bg => "252525"

      Styles.define :color_rb_blue, :bg => "005"
      Styles.define :color_rb_purple, :bg => "203"

    else

      Styles.define :color_rb_red, :bg => "ffd5d5"
      Styles.define :color_rb_orange, :bg => "ffe5bb"
      Styles.define :color_rb_yellow, :bg => "f9f9aa"
      Styles.define :color_rb_green, :bg => "e0ffcc"
      Styles.define :color_rb_white, :fg=>'222', :bg=>'666', :border=>['666', -1]
      Styles.define :color_rb_light, :bg => "ddd"

      Styles.define :color_rb_blue, :bg => "dde5ff"
      Styles.define :color_rb_purple, :bg => "f2ddff"

    end

    Styles.define :fade7, :fg => "333"
    Styles.define :fade6, :fg => "555"
    Styles.define :fade5, :fg => "777"
    Styles.define :fade4, :fg => "999"
    Styles.define :fade3, :fg => "bbb"
    Styles.define :fade2, :fg => "ddd"
    Styles.define :fade1, :fg => "fff"

  end

  def self.get_marked_lines label=nil
Ol.stack 3

    overlays = $el.overlays_in(View.top, View.bottom)   # Get all overlays
    txt = ""
    overlays.to_a.reverse.each do |o|   # Loop through and copy all
      if label
        next if $el.overlay_get(o, :face).to_s != label
      end
      line = View.txt($el.overlay_start(o), $el.overlay_end(o))
      line << "\n" unless line =~ /\n$/
      txt << line
    end
    txt
  end

  # Returns list of colors at cursor
  # Color.at_cursor
  def self.at_cursor
    overlays = $el.overlays_in(Line.left, Line.right)
    overlays = overlays.to_a.reverse.inject([]) do |a, o|   # Loop through and copy all
      a.push $el.overlay_get(o, :face).to_s
    end
  end

  def self.outline
    View.kill if View.name == "@color/mark/"

    txt = self.get_marked_lines
    if txt.blank?
      txt = "    - no marked lines in this view!"
    else
      txt.gsub! /^/, "    | "
    end

    file = View.file

    path = file ?
      "- #{File.expand_path(file).sub(/(.+)\//, "\\1/\n  - ")}\n" :
      "- buffer #{View.name}/\n"

    txt = "#{path}#{txt}"

    Launcher.open txt, :no_launch=>1

    nil
  end



  # Builds up hash of all marks, sorted by time.
  # Structure of hash returned:
  # - key: time
  # - value: [file, line, color]
  def self.all_marks_hash
    hash = {}
    orig = View.buffer

    # For each buffer, add marked lines to hash...

    Buffers.list.to_a.each do |b|  # Each buffer open
      $el.set_buffer b

      file = View.file

      next if ! file   # For now, don't try to handle buffers

      # TODO: Rework to add to hash
      overlays = $el.overlays_in(View.top, View.bottom)   # Get all overlays
      overlays.to_a.each do |o|   # Loop through and copy all
        line = View.txt($el.overlay_start(o), $el.overlay_end(o))
        face = $el.overlay_get(o, :face)
        created_at = $el.overlay_get(o, :created_at)
        next unless created_at && line.any? && face.any?
        face = face.to_s
        next if face == "color-rb-light"
        hash[created_at] = [file, line, face]
      end
    end

    View.to_buffer orig
    hash
  end

  def self.show
    hash = self.all_marks_hash

    if hash.empty?   # If no marks found, just say so
      return "- no marks found!"
    end

    keys = hash.keys.sort.reverse

    txt = ""
    last_file = nil
    keys.each do |key|
      file, line = hash[key]
      if last_file == file   # If same file as last, just add line
        txt << "    | #{line}"
      else # Else, show file and line
        txt << "@#{file.sub /(.+\/)/, "\\1\n  - "}\n    | #{line}"
      end

      last_file = file
    end

    Tree.<< txt, :no_search=>1

    # Apply colors...

    keys.each do |key|
      Move.to_quote
      over = $el.make_overlay(Line.left+Line.indent.length, Line.right+1)
      $el.overlay_put over, :face, hash[key]
    end

    Tree.to_parent :u
    Move.to_quote

    nil
  end

end

Color.define_styles
