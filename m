Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 57F356B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 23:02:43 -0400 (EDT)
Subject: Re: zone state overhead
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1009280907110.6360@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com>
	 <alpine.DEB.2.00.1009280736020.4144@router.home>
	 <20100928133059.GL8187@csn.ul.ie>
	 <alpine.DEB.2.00.1009280838540.6360@router.home>
	 <20100928135148.GM8187@csn.ul.ie>
	 <alpine.DEB.2.00.1009280907110.6360@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Sep 2010 11:02:40 +0800
Message-ID: <1285729360.27440.18.camel@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-09-28 at 22:08 +0800, Christoph Lameter wrote:
> On Tue, 28 Sep 2010, Mel Gorman wrote:
> 
> > On Tue, Sep 28, 2010 at 08:40:15AM -0500, Christoph Lameter wrote:
> > > On Tue, 28 Sep 2010, Mel Gorman wrote:
> > >
> > > > Which of these is better or is there an alternative suggestion on how
> > > > this livelock can be avoided?
> > >
> > > We need to run some experiments to see what is worse. Lets start by
> > > cutting both the stats threshold and the drift thing in half?
> > >
> >
> > Ok, I have no problem with that although again, I'm really not in the position
> > to roll patches for it right now. I don't want to get side-tracked.
> 
> Ok the stat threshold determines the per_cpu_drift_mark.
> 
> So changing the threshold should do the trick. Try this:
doesn't work here, perf still shows the same overhead.

in the system:
Node 3, zone   Normal
pages free     2055926
        min      1441
        low      1801
        high     2161
        scanned  0
        spanned  2097152
        present  2068480
  vm stats threshold: 98
(low-min)/NR_CPU = (1801-1441)/64 = 5
so when the threshold is 5, there is no per_cpu_drift_mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
