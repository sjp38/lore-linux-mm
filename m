Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D1EAF900185
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 07:19:30 -0400 (EDT)
From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Date: Wed, 22 Jun 2011 13:18:51 +0200
Message-Id: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, sassmann@kpanic.de

Following the RFC for the BadRAM feature here's the updated version with
spelling fixes, thanks go to Randy Dunlap. Also the code is now less verbose,
as requested by Andi Kleen.
v2 with even more spelling fixes suggested by Randy.
Patches are against vanilla 2.6.39.
Repost with LKML in Cc as suggested by Andrew Morton.

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
 Documentation/BadRAM.txt            |  370 +++++++++++++++++++++++++++++++++++
 Documentation/kernel-parameters.txt |    6 +
 include/linux/kernel.h              |    1 +
 lib/cmdline.c                       |   35 ++++
 mm/memory-failure.c                 |  100 ++++++++++
 6 files changed, 521 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/BadRAM.txt

-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
