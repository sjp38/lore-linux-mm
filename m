Received: by nf-out-0910.google.com with SMTP id a27so823276nfc
        for <linux-mm@kvack.org>; Sun, 25 Jun 2006 10:55:39 -0700 (PDT)
Message-ID: <449ECE2E.3080804@gmail.com>
Date: Sun, 25 Jun 2006 19:55:58 +0200
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch] 2.6.17: lockless pagecache
References: <20060625163930.GB3006@wotan.suse.de>
In-Reply-To: <20060625163930.GB3006@wotan.suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin napisaA?(a):
> Updated lockless pagecache patchset available here:
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/npiggin/patches/lockless/2.6.17/lockless.patch.gz
> 

Here is my fix for this warnings
WARNING: /lib/modules/2.6.17.1/kernel/fs/ntfs/ntfs.ko needs unknown symbol add_to_page_cache
WARNING: /lib/modules/2.6.17.1/kernel/fs/ntfs/ntfs.ko needs unknown symbol add_to_page_cache

Regards,
Michal

--
Michal K. K. Piotrowski
LTG - Linux Testers Group
(http://www.stardust.webpages.pl/ltg/wiki/)

diff -uprN -X linux-work/Documentation/dontdiff linux-work-clean/mm/filemap.c linux-work/mm/filemap.c
--- linux-work-clean/mm/filemap.c	2006-06-25 19:47:47.000000000 +0200
+++ linux-work/mm/filemap.c	2006-06-25 19:50:43.000000000 +0200
@@ -445,6 +445,8 @@ int add_to_page_cache(struct page *page,
 	return error;
 }

+EXPORT_SYMBOL(add_to_page_cache);
+
 /*
  * Same as add_to_page_cache, but works on pages that are already in
  * swapcache and possibly visible to external lookups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
