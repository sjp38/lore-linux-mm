Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 1BEC56B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 10:40:37 -0400 (EDT)
Date: Thu, 12 Sep 2013 15:40:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 41/50] sched: numa: Use {cpu, pid} to create task groups
 for shared faults
Message-ID: <20130912144031.GU22421@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-42-git-send-email-mgorman@suse.de>
 <CAJd=RBBOHXT=7NGAkLtcOCMna5g2GvaQG-Xc0mzrbp_mOQ4xyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAJd=RBBOHXT=7NGAkLtcOCMna5g2GvaQG-Xc0mzrbp_mOQ4xyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 12, 2013 at 08:42:18PM +0800, Hillf Danton wrote:
> Hello Mel
> 
> On Tue, Sep 10, 2013 at 5:32 PM, Mel Gorman <mgorman@suse.de> wrote:
> >
> > +void task_numa_free(struct task_struct *p)
> > +{
> > +       struct numa_group *grp = p->numa_group;
> > +       int i;
> > +
> > +       kfree(p->numa_faults);
> > +
> > +       if (grp) {
> > +               for (i = 0; i < 2*nr_node_ids; i++)
> > +                       atomic_long_sub(p->numa_faults[i], &grp->faults[i]);
> > +
> use after free, numa_faults ;/
> 

It gets fixed in the patch "sched: numa: use group fault statistics in
numa placement" but I agree that it's the wrong place to fix it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
