Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6AF716B0038
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 16:11:58 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id h186so16713108vkg.17
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 13:11:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id r30si1356611uaf.139.2017.03.30.13.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Mar 2017 13:11:57 -0700 (PDT)
From: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Subject: [PATCH 0/9] convert genericirq.tmpl and kernel-api.tmpl to DocBook
Date: Thu, 30 Mar 2017 17:11:27 -0300
Message-Id: <cover.1490904090.git.mchehab@s-opensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Media Mailing List <linux-media@vger.kernel.org>, Linux Doc Mailing List <linux-doc@vger.kernel.org>
Cc: Mauro Carvalho Chehab <mchehab@s-opensource.com>, Mauro Carvalho Chehab <mchehab@infradead.org>, Noam Camus <noamca@mellanox.com>, James Morris <james.l.morris@oracle.com>, zijun_hu <zijun_hu@htc.com>, Markus Heiser <markus.heiser@darmarit.de>, linux-clk@vger.kernel.org, Jani Nikula <jani.nikula@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nicholas Piggin <npiggin@gmail.com>, Russell King <linux@armlinux.org.uk>, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, "Serge E. Hallyn" <serge@hallyn.com>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Silvio Fricke <silvio.fricke@gmail.com>, Takashi Iwai <tiwai@suse.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-pci@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Alexey Dobriyan <adobriyan@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Jani proposed to batch-convert the remaining DocBooks for us
to get rid of it.

Well, I tried ;) 

The conversion itself can easily done, but the problem is that
it hits several errors/warnings when parsing kernel-doc tags.

It ends that it takes some time to fix those.

Also, it seems that the "!I" and "!E" tags at the DocBook
template are not quite right. So, despite being properly
converted to the corresponding kernel-doc tags at ReST, they
didn't produce all that it was needed. I manually fixed a
few, but I guess there are more to be fixed there. Anyway,
this is something that the subsystem maintainers can fix later,
as they understand better what functions they want exported at
the public API documentation, and what functions they want to
hide.

This series converts just two documents, adding them to the
core-api.rst book. It addresses the errors/warnings that popup
after the conversion.

I had to add two fixes to scripts/kernel-doc, in order to solve
some of the issues.

If I have some time during this weekend, I may try to convert
some additional documents to DocBook.


Mauro Carvalho Chehab (9):
  scripts/kernel-doc: fix parser for apostrophes
  scripts/kernel-doc: fix handling of parameters with parenthesis
  genericirq.tmpl: convert it to ReST
  genericirq.rst: add cross-reference links and use monospaced fonts
  kernel-api.tmpl: convert it to ReST
  kernel-api.rst: fix output of the vsnprintf() documentation
  kernel-api.rst: make it handle lib/crc32.c
  kernel-api.rst: fix some complex tags at lib/bitmap.c
  kernel-api.rst: fix a series of errors when parsing C files

 Documentation/DocBook/Makefile        |   4 +-
 Documentation/DocBook/genericirq.tmpl | 520 ----------------------------------
 Documentation/DocBook/kernel-api.tmpl | 331 ----------------------
 Documentation/core-api/genericirq.rst | 440 ++++++++++++++++++++++++++++
 Documentation/core-api/index.rst      |   2 +
 Documentation/core-api/kernel-api.rst | 418 +++++++++++++++++++++++++++
 block/genhd.c                         |   7 +-
 drivers/pci/irq.c                     |   2 +-
 include/linux/clk.h                   |   4 +-
 ipc/util.c                            |  12 +-
 lib/bitmap.c                          |  28 +-
 lib/string.c                          |   2 +-
 lib/vsprintf.c                        |   6 +-
 mm/filemap.c                          |  18 +-
 mm/page_alloc.c                       |   3 +-
 mm/vmalloc.c                          |   2 +-
 scripts/kernel-doc                    |  19 +-
 security/security.c                   |  12 +-
 18 files changed, 932 insertions(+), 898 deletions(-)
 delete mode 100644 Documentation/DocBook/genericirq.tmpl
 delete mode 100644 Documentation/DocBook/kernel-api.tmpl
 create mode 100644 Documentation/core-api/genericirq.rst
 create mode 100644 Documentation/core-api/kernel-api.rst

-- 
2.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
