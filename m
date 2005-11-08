Date: Mon, 7 Nov 2005 18:44:06 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: Cleanup of __alloc_pages
Message-Id: <20051107184406.3179757c.akpm@osdl.org>
In-Reply-To: <1131416195.20471.31.camel@akash.sc.intel.com>
References: <20051107174349.A8018@unix-os.sc.intel.com>
	<20051107175358.62c484a3.akpm@osdl.org>
	<1131416195.20471.31.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rohit Seth <rohit.seth@intel.com> wrote:
>
> On Mon, 2005-11-07 at 17:53 -0800, Andrew Morton wrote:
> > "Rohit, Seth" <rohit.seth@intel.com> wrote:
> > >
> > > [PATCH]: Clean up of __alloc_pages. Couple of difference from original behavior:
> > > 	1- remove the initial reclaim logic
> > > 	2- GFP_HIGH pages are allowed to go little below watermark sooner.
> > > 	3- Search for free pages unconditionally after direct reclaim.
> > 
> > Would it be possible to break these into three separate patches?  The
> > cleanup part should be #1.
> > 
> 
> Doing the above three things as part of this clean up patch makes the
> code look extra clean...

With separate patches the changes can be better understood, and they can be
selectively dropped, and people looking for regressions with `git bisect'
will be able to pinpoint the source more accurately.

> Is there any specific issue coming out of 2 & 3
> above.

I haven't looked yet - all the changes are mixed together ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
