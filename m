Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BCB08D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 01:52:57 -0500 (EST)
Subject: Re: [PATCH 2/2 v3]mm: batch activate_page() to reduce lock
 contention
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20110308150937.7EC5.A69D9226@jp.fujitsu.com>
References: <20110308134633.7EBF.A69D9226@jp.fujitsu.com>
	 <AANLkTikBKemiS1aJB-MrHXwefHxKs2gGX6w=J1oQqJd-@mail.gmail.com>
	 <20110308150937.7EC5.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Mar 2011 14:52:03 +0800
Message-ID: <1299567123.2337.32.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 2011-03-08 at 14:10 +0800, KOSAKI Motohiro wrote:
> > On Tue, Mar 8, 2011 at 1:47 PM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > >> > > +#ifdef CONFIG_SMP
> > >> > > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
> > >> >
> > >> > Why do we have to handle SMP and !SMP?
> > >> > We have been not separated in case of pagevec using in swap.c.
> > >> > If you have a special reason, please write it down.
> > >> this is to reduce memory footprint as suggested by akpm.
> > >>
> > >> Thanks,
> > >> Shaohua
> > >
> > > Hi Shaouhua,
> > >
> > > I agree with you. But, please please avoid full quote. I don't think
> > > it is so much difficult work. ;-)
> > 
> > I didn't want to add new comment in the code but want to know why we
> > have to care of activate_page_pvecs specially. I think it's not a
> > matter of difficult work or easy work. If new thing is different with
> > existing things, at least some comment in description makes review
> > easy.
> > 
> > If it's memory footprint issue, should we care of other pagevec to
> > reduce memory footprint in non-smp? If it is, it would be a TODO list
> > for consistency and memory footprint.
> 
> Yeah. indeed.
> Shaoua, If my remember is correct, your previous version has code size
> comparision result. could you resurrect it?
sure thing. I'll add it in next post.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
