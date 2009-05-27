Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0A8236B008A
	for <linux-mm@kvack.org>; Wed, 27 May 2009 14:24:05 -0400 (EDT)
Date: Wed, 27 May 2009 14:23:07 -0400
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH] drm: i915: ensure objects are allocated below 4GB on
	PAE
Message-ID: <20090527182307.GA30228@bombadil.infradead.org>
References: <20090526162717.GC14808@bombadil.infradead.org> <Pine.LNX.4.64.0905262343140.13452@sister.anvils> <20090527001840.GC16929@bombadil.infradead.org> <20090527004250.GA11835@sli10-desk.sh.intel.com> <1243446012.8400.37.camel@gaiman.anholt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243446012.8400.37.camel@gaiman.anholt.net>
Sender: owner-linux-mm@kvack.org
To: Eric Anholt <eric@anholt.net>
Cc: Shaohua Li <shaohua.li@intel.com>, Kyle McMartin <kyle@mcmartin.ca>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, "airlied@redhat.com" <airlied@redhat.com>, "dri-devel@lists.sf.net" <dri-devel@lists.sf.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>, "stable@kernel.org" <stable@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 10:40:12AM -0700, Eric Anholt wrote:
> On Wed, 2009-05-27 at 08:42 +0800, Shaohua Li wrote:
> > On Wed, May 27, 2009 at 08:18:40AM +0800, Kyle McMartin wrote:
> > > On Tue, May 26, 2009 at 11:55:50PM +0100, Hugh Dickins wrote:
> > > > I'm confused: I thought GFP_DMA32 only applies on x86_64:
> > > > my 32-bit PAE machine with (slightly!) > 4GB shows no ZONE_DMA32.
> > > > Does this patch perhaps depend on another, to enable DMA32 on 32-bit
> > > > PAE, or am I just in a muddle?
> > > > 
> > > 
> > > No, you're exactly right, I'm just a muppet and missed the obvious.
> > > Looks like the "correct" fix is the fact that the allocation is thus
> > > filled out with GFP_USER, therefore, from ZONE_NORMAL, and below
> > > max_low_pfn.
> > > 
> > > Looks like we'll need some additional thinking to get true ZONE_DMA32 on
> > > i386... ugh, I'll look into it tonight.
> > For i386, GFP_USER is enough. But 945G GART can only map to physical page < 4G,
> > so for x64, we need GFP_DMA32. This is the reason I add extra GFP_DMA32.
> 
> Those 945Gs don't have memory located above 4G, from my reading of the
> chipset specs.
> 

Indeed, I thought they were clipped to 3G memory, max. (I assume we mean
945 in the strictest sense, and not "son of 945" like the G33 series?)

(But yeah, the ifdef in my patch should be nuked strictly, I guess.)

cheers, Kyle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
