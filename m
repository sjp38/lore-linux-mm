Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0D51D6B002C
	for <linux-mm@kvack.org>; Sun, 26 Feb 2012 18:56:13 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1A9913EE0BD
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 08:56:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E5EE445DE54
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 08:56:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD6C445DE51
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 08:56:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD0041DB8042
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 08:56:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 73DFB1DB803E
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 08:56:11 +0900 (JST)
Date: Mon, 27 Feb 2012 08:54:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 00/21] mm: lru_lock splitting
Message-Id: <20120227085438.06f8673e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F487215.7000307@openvz.org>
References: <20120223133728.12988.5432.stgit@zurg>
	<20120225111515.1275e04c.kamezawa.hiroyu@jp.fujitsu.com>
	<4F487215.7000307@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On Sat, 25 Feb 2012 09:31:01 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Thu, 23 Feb 2012 17:51:36 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> >
> >> v3 changes:
> >> * inactive-ratio reworked again, now it always calculated from from scratch
> >> * hierarchical pte reference bits filter in memory-cgroup reclaimer
> >> * fixed two bugs in locking, found by Hugh Dickins
> >> * locking functions slightly simplified
> >> * new patch for isolated pages accounting
> >> * new patch with lru interleaving
> >>
> >> This patchset is based on next-20120210
> >>
> >> git: https://github.com/koct9i/linux/commits/lruvec-v3
> >>
> >
> > I wonder.... I just wonder...if we can split a lruvec in a zone into small
> > pieces of lruvec and have splitted LRU-lock per them, do we need per-memcg-lrulock ?
> 
> What per-memcg-lrulock? I don't have it.
> last patch splits lruvecs in memcg with the same factor.
> 
Okay, I missed it.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
