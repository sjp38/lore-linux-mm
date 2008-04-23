Date: Wed, 23 Apr 2008 17:36:18 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 18/18] hugetlb: my fixes 2
Message-ID: <20080423153618.GC16769@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.569358000@nick.local0.net> <480F13F5.9090003@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480F13F5.9090003@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 12:48:21PM +0200, Andi Kleen wrote:
> npiggin@suse.de wrote:
> 
> Thanks for these fixes. The subject definitely needs improvement, or
> rather all these fixes should be folded into the original patches.

Yes that's what I intend. I just have the broken out patch at the end
so it is easy to review. Afterwards I will fold it into your patches.

 
> > Here is my next set of fixes and changes:
> > - Allow configurations without the default HPAGE_SIZE size (mainly useful
> >   for testing but maybe it is the right way to go).
> 
> I don't think it is the correct way. If you want to do it this way you
> would need to special case it in /proc/meminfo to keep things compatible.
> 
> Also in general I would think that always keeping the old huge page size
> around is a good idea. There is some chance at least to allocate 2MB
> pages after boot (especially with the new movable zone and with lumpy
> reclaim), so it doesn't need to be configured at boot time strictly. And
> why take that option away from the user?
> 
> Also I would hope that distributions keep their existing /hugetlbfs
> (if they have one) at the compat size for 100% compatibility to existing
> applications.

You are probably right on all counts here. I did intend to stress
that it was mainly for my ease of testing and I don't know so
much about the userspace aspect of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
