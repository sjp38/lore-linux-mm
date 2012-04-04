Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 004006B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 02:49:05 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1008502iaj.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 23:49:05 -0700 (PDT)
Date: Tue, 3 Apr 2012 23:49:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb.c: cleanup to use long vars instead of int
 in region_count
In-Reply-To: <alpine.DEB.2.00.1203071331150.15255@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1204032348470.3865@chino.kir.corp.google.com>
References: <4EE6F24B.7050204@gmail.com> <alpine.DEB.2.00.1203071331150.15255@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wang Sheng-Hui <shhuiw@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 7 Mar 2012, David Rientjes wrote:

> On Tue, 13 Dec 2011, Wang Sheng-Hui wrote:
> 
> > args f & t and fields from & to of struct file_region are defined
> > as long. Use long instead of int to type the temp vars.
> > 
> > Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> > ---
> >  mm/hugetlb.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index dae27ba..e666287 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -195,8 +195,8 @@ static long region_count(struct list_head *head, long f, long t)
> >  
> >  	/* Locate each segment we overlap with, and count that overlap. */
> >  	list_for_each_entry(rg, head, link) {
> > -		int seg_from;
> > -		int seg_to;
> > +		long seg_from;
> > +		long seg_to;
> >  
> >  		if (rg->to <= f)
> >  			continue;
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Andrew, it looks like this never made it to linux-next.
> 

Still not in linux-next as of today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
