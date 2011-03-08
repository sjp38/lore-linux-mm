Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AB5798D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 01:10:41 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B39DD3EE0C5
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:10:38 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93D0E45DE5D
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:10:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B6D045DE58
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:10:38 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AC1CE38003
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:10:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 32C611DB804A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 15:10:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2 v3]mm: batch activate_page() to reduce lock contention
In-Reply-To: <AANLkTikBKemiS1aJB-MrHXwefHxKs2gGX6w=J1oQqJd-@mail.gmail.com>
References: <20110308134633.7EBF.A69D9226@jp.fujitsu.com> <AANLkTikBKemiS1aJB-MrHXwefHxKs2gGX6w=J1oQqJd-@mail.gmail.com>
Message-Id: <20110308150937.7EC5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  8 Mar 2011 15:10:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

> On Tue, Mar 8, 2011 at 1:47 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> > > +#ifdef CONFIG_SMP
> >> > > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
> >> >
> >> > Why do we have to handle SMP and !SMP?
> >> > We have been not separated in case of pagevec using in swap.c.
> >> > If you have a special reason, please write it down.
> >> this is to reduce memory footprint as suggested by akpm.
> >>
> >> Thanks,
> >> Shaohua
> >
> > Hi Shaouhua,
> >
> > I agree with you. But, please please avoid full quote. I don't think
> > it is so much difficult work. ;-)
> 
> I didn't want to add new comment in the code but want to know why we
> have to care of activate_page_pvecs specially. I think it's not a
> matter of difficult work or easy work. If new thing is different with
> existing things, at least some comment in description makes review
> easy.
> 
> If it's memory footprint issue, should we care of other pagevec to
> reduce memory footprint in non-smp? If it is, it would be a TODO list
> for consistency and memory footprint.

Yeah. indeed.
Shaoua, If my remember is correct, your previous version has code size
comparision result. could you resurrect it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
