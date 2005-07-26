Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6QKbnkQ680216
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 16:37:49 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6QKbn9v406176
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 14:37:49 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6QKbmTf006984
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 14:37:49 -0600
Subject: Re: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050726193138.GA32324@kevlar.burdell.org>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726111110.6b9db241.akpm@osdl.org>
	 <1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726193138.GA32324@kevlar.burdell.org>
Content-Type: text/plain
Date: Tue, 26 Jul 2005 13:37:36 -0700
Message-Id: <1122410256.6433.43.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sonny Rao <sonny@burdell.org>
Cc: Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-26 at 15:31 -0400, Sonny Rao wrote:
> On Tue, Jul 26, 2005 at 11:39:11AM -0700, Badari Pulavarty wrote:
> > On Tue, 2005-07-26 at 11:11 -0700, Andrew Morton wrote:
> > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > >
> > > > After KS & OLS discussions about memory pressure, I wanted to re-do
> > > >  iSCSI testing with "dd"s to see if we are throttling writes.  
> > > > 
> > > >  I created 50 10-GB ext3 filesystems on iSCSI luns. Test is simple
> > > >  50 dds (one per filesystem). System seems to throttle memory properly
> > > >  and making progress. (Machine doesn't respond very well for anything
> > > >  else, but my vmstat keeps running - 100% sys time).
> > > 
> > > It's important to monitor /proc/meminfo too - the amount of dirty/writeback
> > > pages, etc.
> > > 
> > > btw, 100% system time is quite appalling.  Are you sure vmstat is telling
> > > the truth?  If so, where's it all being spent?
> > > 
> > > 
> > 
> > Well, profile doesn't show any time in "default_idle". So
> > I believe, vmstat is telling the truth.
> 
> Badari,
> 
> You probably covered this, but just to make sure, if you're on a
> pentium4 machine, I usually boot w/ "idle=poll" to see proper idle
> reporting because otherwise the chip will throttle itself back and
> idle time will be skewed -- at least on oprofile.
> 

My machine is AMD64.

- Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
