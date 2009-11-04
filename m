Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CC6316B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 15:40:11 -0500 (EST)
Date: Wed, 4 Nov 2009 13:40:08 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH] page-types: decode flags directly from command line
Message-ID: <20091104204008.GA8211@ldl.fc.hp.com>
References: <20091103225441.GB4087@grease> <20091104121832.GB26504@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091104121832.GB26504@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, "Li, Haicheng" <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

Hi Fengguang,

* Wu Fengguang <fengguang.wu@intel.com>:
> On Wed, Nov 04, 2009 at 06:54:41AM +0800, Alex Chiang wrote:
> > Why is this useful? For instance, if you're using memory hotplug
> > and see this in /var/log/messages:
> > 
> > 	kernel: removing from LRU failed 3836dd0/1/1e00000000000400
> > 
> > It would be nice to decode those page flags without staring at
> > the source.
> 
> In fact it's more than decode - encoding is also possible with the
> _same_ code! So maybe "-d" and help message will not be all that
> appropriate.

I'm sorry, I don't understand this use case, so I'm not sure what
you're asking me to do.

You're saying that a use case would be something like:

	./page-types --encode referenced,mmap
	0x0000000000000004

?

If that's what you're asking for, I guess I'm not sure why that's
so useful, but then again, I'm a vm n00b so there are probably
lots of things I don't understand. ;)

> > Example usage and output:
> > 
> > linux-2.6/Documentation/vm$ ./page-types -d 0x1e00000000000400
> >              flags	page-count       MB  symbolic-flags			long-symbolic-flags
> > 0x1e00000000000400	         1        0  __________B_______________________buddy
> >              total	         1        0
> 
> The output is a bit redundant - so does the code. Could you simplify
> them a bit?

Well, the code is redundant, but add_page() / show_summary() is a
simple sequence.

In contrast, I think I'd have to modify walk_addr_ranges() and
maybe walk_pfn() to do something special when we don't really
want to do any address space walking, and simply want to
decode/encode some user input.

Maybe I don't understand you fully? Could you give me a better
idea of what you're looking for?

As for the output, I'm just reusing show_summary(). Maybe we
don't need the flags, page-count, and MB columns, but again, the
patch would be more intrusisive because we'd have to teach
show_summary() about the special case.

Anyway, I'm happy to make changes closer to what you're looking
for, but I'd like some more guidance as to what you're expecting.

Thanks,
/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
