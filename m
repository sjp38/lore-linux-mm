Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E9AAD6B0082
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:08:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n598bPVQ027784
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 17:37:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C737045DD79
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:37:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A114745DD76
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:37:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FBCCE08009
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:37:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C4E3E08001
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:37:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] vmscan: handle may_swap more strictly (Re: [PATCH  mmotm] vmscan: fix may_swap handling for memcg)
In-Reply-To: <28c262360906090135x3382456by3518434a9939002b@mail.gmail.com>
References: <20090609172035.DD7C.A69D9226@jp.fujitsu.com> <28c262360906090135x3382456by3518434a9939002b@mail.gmail.com>
Message-Id: <20090609173605.DD82.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 17:37:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jun 9, 2009 at 5:24 PM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> >> On Tue, Jun 9, 2009 at 4:58 PM, KOSAKI
> >> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> >> >> Hi, KOSAKI.
> >> >>
> >> >> As you know, this problem caused by if condition(priority) in shrink_zone.
> >> >> Let me have a question.
> >> >>
> >> >> Why do we have to prevent scan value calculation when the priority is zero ?
> >> >> As I know, before split-lru, we didn't do it.
> >> >>
> >> >> Is there any specific issue in case of the priority is zero ?
> >> >
> >> > Yes.
> >> >
> >> > example:
> >> >
> >> > get_scan_ratio() return anon:80%, file=20%. and the system have
> >> > 10000 anon pages and 10000 file pages.
> >> >
> >> > shrink_zone() picked up 8000 anon pages and 2000 file pages.
> >> > it mean 8000 file pages aren't scanned at all.
> >> >
> >> > Oops, it can makes OOM-killer although system have droppable file cache.
> >> >
> >> Hmm..Can that problem be happen in real system ?
> >> The file ratio is big means that file lru list scanning is so big but
> >> rotate is small.
> >> It means file lru have few reclaimable page.
> >>
> >> Isn't it ? I am confusing.
> >> Could you elaborate, please if you don't mind ?
> >
> > hm, ok, my example was wrong.
> > I intention is, if there are droppable file-back pages (althout only 1 page),
> > OOM-killer shouldn't occuer.
> >
> > many or few is unrelated.
> >
> 
> I am not sure that is effective.
> Have you ever met this problem in real situation ?

No.
It's only stress workload issue. but VM subsystem sould work on
stress workload, I think.


> BTW, I have to dive into code. :)
> Thanks for spending valuable time for commenting





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
