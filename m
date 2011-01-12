Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D412C6B0092
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 19:50:56 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 425563EE0AE
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:50:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2749A45DE58
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:50:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FE8245DE56
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:50:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 028FB1DB803B
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:50:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2741DB8037
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:50:53 +0900 (JST)
Date: Wed, 12 Jan 2011 09:44:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] mm: add replace_page_cache_page() function
Message-Id: <20110112094453.8197ee36.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110111142528.GF2113@barrios-desktop>
References: <E1Pcet8-0007kg-3R@pomaz-ex.szeredi.hu>
	<20110111142528.GF2113@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011 23:25:28 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Jan 11, 2011 at 03:07:54PM +0100, Miklos Szeredi wrote:
> > (resent with fixed CC list, sorry for the duplicate)
> > 
> > Thanks for the review.
> > 
> > Here's an updated patch.  Modifications since the last post:
> > 
> >  - don't pass gfp_mask (since it's only able to deal with GFP_KERNEL
> >    anyway)
> > 
> 
> I am not sure it's a good idea.
> Now if we need just GFP_KERNEL, we can't make sure it in future.
> Sometime we might need GFP_ATOMIC and friendd functions
> (ex, add_to_page_cache_lru,add_to_page_cache_locked) already have gfp_mask.
> It's a exported function so it's hard to modify it in future.
> 
> I want to keep it.
> Instead of removing it, we can change mem_cgroup_prepare_migration as
> getting gfp_mask.
> 
you're right.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
