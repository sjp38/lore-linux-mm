Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7A3116B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:17:08 -0400 (EDT)
From: Stefan Assmann <sassmann@kpanic.de>
Subject: [RFC PATCH 0/3] support for broken memory modules (BadRAM)
Date: Wed, 27 Apr 2011 18:16:44 +0200
Message-Id: <1303921007-1769-1-git-send-email-sassmann@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, akpm@linux-foundation.org, lwoodman@redhat.com, riel@redhat.com, sassmann@kpanic.de

This is a RFC for the BadRAM feature originally developed by Rick van Rein.
Patches are against vanilla 2.6.38.

The idea is to allow the user to specify RAM addresses that shouldn't be
touched by the OS, because they are broken in some way. Not all machines have
hardware support for hwpoison, ECC RAM, etc, so here's a solution that allows to
use bitmasks to mask address patterns with the new "badram" kernel command line
parameter.
Memtest86 has an option to generate these patterns since v2.3 so the only thing
for the user to do should be:
- run Memtest86
- note down the pattern
- add badram=<pattern> to the kernel command line

The concerning pages are then marked with the hwpoison flag and thus won't be
used by the memory managment system.

Link to Ricks original patches and docs:
http://rick.vanrein.org/linux/badram/

  Stefan

Stefan Assmann (3):
  Add string parsing function get_next_ulong
  support for broken memory modules (BadRAM)
  Add documentation and credits for BadRAM

 CREDITS                             |    9 +
 Documentation/BadRAM.txt            |  369 +++++++++++++++++++++++++++++++++++
 Documentation/kernel-parameters.txt |    5 +
 include/linux/kernel.h              |    1 +
 lib/cmdline.c                       |   35 ++++
 mm/memory-failure.c                 |   95 +++++++++
 6 files changed, 514 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/BadRAM.txt

-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
