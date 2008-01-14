Date: Mon, 14 Jan 2008 11:51:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] mmu notifiers
In-Reply-To: <478A03D8.9050308@qumranet.com>
Message-ID: <Pine.LNX.4.64.0801141150010.8300@schroedinger.engr.sgi.com>
References: <20080109181908.GS6958@v2.random>
 <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com>
 <47860512.3040607@qumranet.com> <Pine.LNX.4.64.0801101103470.20353@schroedinger.engr.sgi.com>
 <47891A5C.8060907@qumranet.com> <20080113120939.GA3221@sgi.com>
 <478A03D8.9050308@qumranet.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

On Sun, 13 Jan 2008, Avi Kivity wrote:

> I was just explaining how kvm shares memory among guests (which does not
> require mmu notifiers); if you have some other configuration that can benefit
> from mmu notifiers, then, well, great.

I think you have two page tables pointing to the same memory location 
right (not to page structs but two ptes)? Without a mmu notifier the pages 
in this memory range cannot be evicted because otherwise ptes of the other 
instance will point to a page that is now used for a different purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
