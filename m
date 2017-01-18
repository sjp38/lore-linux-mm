Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 813C76B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 00:49:47 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so5110681pgc.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 21:49:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id o1si11880270pld.201.2017.01.17.21.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 21:49:46 -0800 (PST)
Date: Tue, 17 Jan 2017 21:49:45 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [ATTEND] many topics
Message-ID: <20170118054945.GD18349@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org


o/~ There are many things that I would like to say to you ... o/~

mostly around MM and FS interaction.

1. Exploiting multiorder radix tree entries.  I believe we would do well
to attempt to allocate compound pages, insert them into the page cache,
and expect filesystems to be able to handle filling compound pages with
->readpage.  It will be more efficient because alloc_pages() can return
large entries out of the buddy list rather than breaking them down,
and it'll help reduce fragmentation.

2. Supporting filesystem block sizes > page size.  Once we do the above
for efficiency, I think it then becomes trivial to support, eg 16k block
size filesystems on x86 machines with 4k pages.

3. Moving slab objects.  I've been working with Christoph Lameter
this week on implementing a reclaim operation for radix tree nodes.
It seems feasible.  We should probably talk about reclaming dentries
and inodes as well.

4. Pretty much anything relating to DAX.  See other thread.

5. I have discovered a newfound fascination with CIFS which is totally
unrelated to my new employer.  Honest.  I should have some interesting
patches for CIFS by LSFMM.

6. Overhauling vmap to use a radix tree instead of a possibly recursive
vmalloc of an array to store pointers to the pages.

7. Using alloc_pages_exact() to kmalloc objects larger than PAGE_SIZE*2

8. Nailing down exactly what GFP_TEMPORARY means

9. Adding malloc()/free() as a kernel API

I have more things in my IDEAS file, but I think that will do for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
