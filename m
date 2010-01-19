Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CE81C6B006A
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 09:33:59 -0500 (EST)
Date: Tue, 19 Jan 2010 15:33:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/1] bootmem: move big allocations behing 4G
Message-ID: <20100119143355.GB7932@cmpxchg.org>
References: <1263855390-32497-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1263855390-32497-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Ralf Baechle <ralf@linux-mips.org>, x86@kernel.org
List-ID: <linux-mm.kvack.org>

Hello Jiri,

On Mon, Jan 18, 2010 at 11:56:30PM +0100, Jiri Slaby wrote:
> Hi, I'm fighting a bug where Grub loads the kernel just fine, whereas
> isolinux doesn't. I found out, it's due to different addresses of
> loaded initrd. On a machine with 128G of memory, grub loads the
> initrd at 895M in our case and flat mem_map (2G long) is allocated
> above 4G due to 2-4G BIOS reservation.
> 
> On the other hand, with isolinux, the 0-2G is free and mem_map is
> placed there leaving no space for others, hence kernel panics for
> swiotlb which needs to be below 4G.

Bootmem already protects the lower 16MB DMA zone for the obvious reasons,
how about shifting the default bootmem goal above the DMA32 zone if it exists?

I added Ralf and the x86 Team on Cc as this only affects x86 and mips, afaics.

> Any ideas?

I tested the below on a rather dull x86_64 machine and it seems to work.  Would
this work in your case as well?  The goal for mem_map should now be above 4G.

	Hannes
