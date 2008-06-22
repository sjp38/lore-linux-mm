Date: Sun, 22 Jun 2008 11:18:07 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: fix race in COW logic
In-Reply-To: <Pine.LNX.4.64.0806221854050.5466@blonde.site>
Message-ID: <alpine.LFD.1.10.0806221115070.2926@woody.linux-foundation.org>
References: <20080622153035.GA31114@wotan.suse.de> <Pine.LNX.4.64.0806221742330.31172@blonde.site> <alpine.LFD.1.10.0806221033200.2926@woody.linux-foundation.org> <Pine.LNX.4.64.0806221854050.5466@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


On Sun, 22 Jun 2008, Hugh Dickins wrote:
> 
> I'm puzzled.

No, you're right. It was me who was confused. The pages are different, 
duh, and yes, there's a SMP memory ordering issue between updating the 
new page table entry and decrementing the use count for the old page.

My bad. Ignore me.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
