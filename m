Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ED27060021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 12:32:03 -0500 (EST)
Date: Wed, 9 Dec 2009 11:31:20 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
In-Reply-To: <4B1E1B1B0200007800024345@vpn.id2.novell.com>
Message-ID: <alpine.DEB.2.00.0912091128280.16491@router.home>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: tony.luck@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Dec 2009, Jan Beulich wrote:

> According to Tejun the problem is just cosmetic (i.e. causes build
> warnings), since the functions affected aren't being used (yet) on
> ia64. So feel free to drop the patch again, given that he has a patch
> queued to address the issue by renaming the arch variable.

I thought the new code must be used in order for the new percpu allocator
to work? Or is this referring to other code?

> I wonder though why that code is being built on ia64 at all if it's not
> being used (i.e. why it doesn't depend on a CONFIG_*, HAVE_*, or
> NEED_* manifest constant).

Tony: Can you confirm that the new percpu stuff works on IA64? (Or is
there nobody left to care?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
