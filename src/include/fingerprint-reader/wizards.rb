# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006-2012 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

# File:	include/fingerprint-reader/wizards.ycp
# Package:	Configuration of fingerprint-reader
# Summary:	Wizards definitions
# Authors:	Jiri Suchomel <jsuchome@suse.cz>
#
# $Id$
module Yast
  module FingerprintReaderWizardsInclude
    def initialize_fingerprint_reader_wizards(include_target)
      Yast.import "UI"

      textdomain "fingerprint-reader"

      Yast.import "Sequencer"
      Yast.import "Wizard"

      Yast.include include_target, "fingerprint-reader/dialogs.rb"
    end

    # Main workflow of the fingerprint-reader configuration
    # @return sequence result
    def MainSequence
      aliases = { "summary" => lambda { FingerprintReaderDialog() } }

      sequence = {
        "ws_start" => "summary",
        "summary"  => { :abort => :abort, :next => :next }
      }

      ret = Sequencer.Run(aliases, sequence)

      deep_copy(ret)
    end

    # Whole configuration of fingerprint-reader
    # @return sequence result
    def FingerprintReaderSequence
      aliases = {
        "read"  => [lambda { ReadDialog() }, true],
        "main"  => lambda { MainSequence() },
        "write" => [lambda { WriteDialog() }, true]
      }

      sequence = {
        "ws_start" => "read",
        "read"     => { :abort => :abort, :next => "main" },
        "main"     => { :abort => :abort, :next => "write" },
        "write"    => { :abort => :abort, :next => :next }
      }

      Wizard.CreateDialog

      ret = Sequencer.Run(aliases, sequence)

      UI.CloseDialog
      deep_copy(ret)
    end

    # Whole configuration of fingerprint-reader but without reading and writing.
    # For use with autoinstallation.
    # @return sequence result
    def FingerprintReaderAutoSequence
      # Initialization dialog caption
      caption = _("Fingerprint Reader Configuration")
      # Initialization dialog contents
      contents = Label(_("Initializing..."))

      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        caption,
        contents,
        "",
        Label.BackButton,
        Label.NextButton
      )

      ret = MainSequence()

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end
