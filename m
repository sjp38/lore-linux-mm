Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6F83860021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 13:47:07 -0500 (EST)
Date: Wed, 9 Dec 2009 12:46:24 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
In-Reply-To: <4B1FEE5C.1030303@sgi.com>
Message-ID: <alpine.DEB.2.00.0912091241370.16491@router.home>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com> <alpine.DEB.2.00.0912091128280.16491@router.home> <4B1FE81F.30408@sgi.com> <alpine.DEB.2.00.0912091218060.16491@router.home>
 <4B1FEE5C.1030303@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mike Travis <travis@sgi.com>
Cc: tony.luck@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009, Mike Travis wrote:

> > Boot with 2.6.32 and see if the per cpu allocator works. Check if there
> > are any changes to memory consumption. Create a few thousand virtual
> > ethernet devices and see if the system keels over.
>
> Any advice on how to go about the above would be helpful... ;-)

I believe you can create an additional alias device with

ifconfig eth0:<N>

or so.

> I'm doing some aim7/9 comparisons right now between SPARSE and DISCONTIG
> memory configs using sles11 + 2.6.32.  Which other benchmarks would you
> recommend for the other tests?

See f.e. http://kernel-perf.sourceforge.net/about_tests.php

lmbench?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
