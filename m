Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
	conditions
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <20051122215838.2abfdbd4.akpm@osdl.org>
References: <20051122161000.A22430@unix-os.sc.intel.com>
	 <20051122213612.4adef5d0.akpm@osdl.org>
	 <20051122215838.2abfdbd4.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 23 Nov 2005 10:17:00 -0800
Message-Id: <1132769820.25086.23.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, christoph@lameter.com
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-22 at 21:58 -0800, Andrew Morton wrote:
> Andrew Morton <akpm@osdl.org> wrote:
> >
> > The `while' loop worries me for some reason, so I wimped out and just tried
> >  the remote drain once.
> 
> Even the `goto restart' which is in this patch worries me from a livelock
> POV.  Perhaps we should only ever run drain_all_local_pages() once per
> __alloc_pages() invokation.
> And perhaps we should run drain_all_local_pages() for GFP_ATOMIC or
> PF_MEMALLOC attempts too.

Good point for PF_MEMALLOC scenario.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
