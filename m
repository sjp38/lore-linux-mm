Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E67206B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 05:43:48 -0400 (EDT)
Date: Mon, 30 May 2011 11:43:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Patch] mm: remove noswapaccount kernel parameter
Message-ID: <20110530094337.GF20166@tiehlicka.suse.cz>
References: <BANLkTinLvqa0DiayLOwvxE9zBmqb4Y7Rww@mail.gmail.com>
 <20110523112558.GC11439@tiehlicka.suse.cz>
 <BANLkTi=2SwKFfwBxrQr3xLYSUzoGOy6oKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTi=2SwKFfwBxrQr3xLYSUzoGOy6oKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Am??rico Wang <xiyou.wangcong@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon 23-05-11 19:50:21, Am??rico Wang wrote:
> On Mon, May 23, 2011 at 7:25 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 23-05-11 19:08:08, Am??rico Wang wrote:
> >> noswapaccount is deprecated by swapaccount=0, and it is scheduled
> >> to be removed in 2.6.40.
> >
> > Similar patch is already in the Andrew's tree
> 
> Ah, my google search failed to find it. :-/
> 
> > (memsw-remove-noswapaccount-kernel-parameter.patch). Andrew, are you
> > going to push it?
> > Btw. the patch is missing documentation part which is present here.
> >
> 
> Hmm, maybe I should send a delta patch... Andrew?

Have you reposted that patch? The primary patch which removes the
paramter already hit the Linus tree (a2c8990a).

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
