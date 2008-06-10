Date: Tue, 10 Jun 2008 14:57:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 17/25] Mlocked Pages are non-reclaimable
Message-Id: <20080610145706.4a921cfa.akpm@linux-foundation.org>
In-Reply-To: <1213134197.6872.49.camel@lts-notebook>
References: <20080606202838.390050172@redhat.com>
	<20080606202859.522708682@redhat.com>
	<20080606180746.6c2b5288.akpm@linux-foundation.org>
	<20080610033130.GK19404@wotan.suse.de>
	<20080610171400.149886cf@cuia.bos.redhat.com>
	<1213134197.6872.49.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: riel@redhat.com, npiggin@suse.de, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Jun 2008 17:43:17 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> Couple of related items:
> 
> + 26-rc5-mm1 + a small fix to the double unlock_page() in
> shrink_page_list() has been running for a couple of hours on my 32G,
> 16cpu ia64 numa platform w/o error.  Seems to have survived the merge
> into -mm, despite the issues Andrew has raised.

oh goody, thanks.  Johannes's bootmem rewrite is holding up
surprisingly well.

gee test.kernel.org takes a long time.

> + on same platform, Mel Gorman's mminit debug code is reporting that
> we're using 22 page flags with Noreclaim, Mlock and PAGEFLAGS_EXTENDED
> configured.

what is "Mel Gorman's mminit debug code"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
