Date: Sun, 19 Aug 2001 03:40:50 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819034050.Z1719@athlon.random>
References: <20010819012713.N1719@athlon.random> <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com> <20010819023548.P1719@athlon.random> <20010819025314.R1719@athlon.random> <20010819032544.X1719@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010819032544.X1719@athlon.random>; from andrea@suse.de on Sun, Aug 19, 2001 at 03:25:44AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

hmm I noticed a superflous change I did, in unmap_fixup the 'area' isn't
visible to the readers (it was just out of the tree), so we can fixup
outside the spinlock, we need to spinlock only before making it visible
again:

	if (end == area->vm_end) {
		lock_vma_mappings(area);
		spin_lock(&mm->page_table_lock);
		area->vm_end = addr;

so in short I can put the area->vm_end = addr back before the
lock_vma...

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
