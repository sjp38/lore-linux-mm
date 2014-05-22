Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id D55446B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 11:41:12 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so9470735wiw.3
        for <linux-mm@kvack.org>; Thu, 22 May 2014 08:41:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id vo4si164407wjc.40.2014.05.22.08.41.10
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 08:41:11 -0700 (PDT)
Date: Thu, 22 May 2014 11:41:00 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15.0-rc6: VM_BUG_ON_PAGE(PageTail(page), page)
Message-ID: <20140522154100.GA30273@redhat.com>
References: <20140522135828.GA24879@redhat.com>
 <537E12D9.6090709@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <537E12D9.6090709@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, May 22, 2014 at 05:08:09PM +0200, Vlastimil Babka wrote:
 
 > > RIP: 0010:[<ffffffffbb718d98>]  [<ffffffffbb718d98>] PageTransHuge.part.23+0xb/0xd
 > > Call Trace:
 > >   [<ffffffffbb1728a3>] isolate_migratepages_range+0x7a3/0x870
 > >   [<ffffffffbb172d90>] compact_zone+0x370/0x560
 > >   [<ffffffffbb173022>] compact_zone_order+0xa2/0x110
 > >   [<ffffffffbb1733f1>] try_to_compact_pages+0x101/0x130
 > > ...
 > > Code: 75 1d 55 be 6c 00 00 00 48 c7 c7 8a 2f a2 bb 48 89 e5 e8 6c 49 95 ff 5d c6 05 74 16 65 00 01 c3 55 31 f6 48 89 e5 e8 28 bd a3 ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 57 45 31 ff 41 56 49 89 fe
 > > RIP  [<ffffffffbb718d98>]
 > >
 > > That BUG is..
 > >
 > > 413 static inline int PageTransHuge(struct page *page)
 > > 414 {
 > > 415         VM_BUG_ON_PAGE(PageTail(page), page);
 > > 416         return PageHead(page);
 > > 417 }
 > 
 > Any idea which of the two PageTransHuge() calls in 
 > isolate_migratepages_range() that is? Offset far in the function suggest 
 > it's where the lru lock is already held, but I'm not sure as decodecode 
 > of your dump and objdump of my own compile look widely different.

Yeah, the only thing the code: matches is the BUG() which is in another section.
(see end of file at http://paste.fedoraproject.org/104155/40077293/raw/)

Maybe you can make more sense of that disassembly than I can..

	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
