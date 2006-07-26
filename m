Date: Thu, 27 Jul 2006 00:59:44 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] vm/agp: remove private page protection map
In-Reply-To: <Pine.LNX.4.64.0607270023120.23571@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0607270059220.17518@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0607181905140.26533@skynet.skynet.ie>
 <Pine.LNX.4.64.0607262135440.11629@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0607270023120.23571@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@linux.ie>
Cc: Andrew Morton <akpm@osdl.org>, Dave Jones <davej@codemonkey.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Jul 2006, Dave Airlie wrote:
> > agp_convert_mmap_flags still using its own conversion from PROT_ to VM_
> > while there's an inline in mm.h (though why someone thought to optimize

My mistake: calc_vm_prot_bits() is actually in include/linux/mman.h
(which you are already #including, so no problem).

> > AGP keeps its own copy of the protection_map, upcoming DRM changes will
> > also require access to this map from modules.
> >
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> 
> Signed-of-by: Dave Airlie <airlied@linux.ie>

Thanks.  By the way, I hope you noticed that some architectures
(arm, m68k, sparc, sparc64) may adjust protection_map[] at startup:
so the old agp_convert_mmap_flags would supply the compiled in prot,
whereas the new agp_convert_mmap_flags supplies the adjusted prot.

I assume this is either irrelevant to you (no AGP on some arches?)
or an improvement (the adjusted prot more appropriate); but if you
weren't aware of it, please do check that those do what you want.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
