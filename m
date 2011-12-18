Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 723206B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 15:43:58 -0500 (EST)
From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 0/4] arch/x86/platform/geode: enhance and expand support for Geode-based platforms, including those using Coreboot
Date: Sun, 18 Dec 2011 13:43:40 -0700
Message-Id: <1324241020-7539-1-git-send-email-philipp_subx@redfish-solutions.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ed Wildgoose <ed@wildgooses.com>, Andrew Morton <akpm@linux-foundation.org>, linux-geode@lists.infradead.org, Andres Salomon <dilinger@queued.net>
Cc: Nathan Williams <nathan@traverse.com.au>, Guy Ellis <guy@traverse.com.au>, David Woodhouse <dwmw2@infradead.org>, Patrick Georgi <patrick.georgi@secunet.com>, linux-mm@kvack.org

From: Philip Prindeville <philipp@redfish-solutions.com>

Many applications running embedded linux use Geode-based single-board
computers. There are many reasons for this, but the low cost bill-of-
materials and the maturity and multiple sourcing of the Geode processor
are amongst the most significant. This collection of patches supplements
the Geode platform support by adding 2 new platforms (Geos and Net5501),
and enhancing one (Alix2) with GPIO-based button support. It also adds
support for detecting Coreboot BIOS and parsing its tables.

Philip Prindeville (4):
  Add support for finding the end-boundary of an E820 region given an  
    address falling in one such region. This is precursory
    functionality for Coreboot loader support.
  Add support for Coreboot BIOS detection. This in turn can be used by 
    platform drivers to verify they are running on the correct
    hardware, as many of the low-volume SBC's (especially in the
    Atom and Geode universe) don't always identify themselves via
    DMI or PCI-ID.
  Trivial platform driver for Traverse Technologies Geos and Geos2    
    single-board computers. Uses Coreboot BIOS to identify platform.   
    Based on progressive revisions of the leds-net5501 driver that    
    was rewritten by Ed Wildgoose as a platform driver.
  Trivial platform driver for Soekris Engineering net5501 single-board 
    computer. Probes well-known locations in ROM for BIOS signature
    to confirm correct platform. Registers 1 LED and 1 GPIO-based
    button (typically used for soft reset).

 Documentation/x86/coreboot.txt    |   31 ++++
 arch/x86/Kconfig                  |   13 ++
 arch/x86/platform/geode/Makefile  |    2 +
 arch/x86/platform/geode/geos.c    |  127 ++++++++++++++++
 arch/x86/platform/geode/net5501.c |  144 ++++++++++++++++++
 drivers/leds/leds-net5501.c       |   97 ------------
 include/linux/coreboot.h          |  182 +++++++++++++++++++++++
 include/linux/ioport.h            |    1 +
 kernel/resource.c                 |   29 ++++
 lib/Kconfig                       |    8 +
 lib/Makefile                      |    1 +
 lib/coreboot.c                    |  290 +++++++++++++++++++++++++++++++++++++
 12 files changed, 828 insertions(+), 97 deletions(-)
 create mode 100644 Documentation/x86/coreboot.txt
 create mode 100644 arch/x86/platform/geode/geos.c
 create mode 100644 arch/x86/platform/geode/net5501.c
 delete mode 100644 drivers/leds/leds-net5501.c
 create mode 100644 include/linux/coreboot.h
 create mode 100644 lib/coreboot.c

-- 
1.7.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
