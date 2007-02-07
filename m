Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l1714iWE005461
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 20:04:44 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l17152n9510738
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 18:05:02 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l17152so025809
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 18:05:02 -0700
Date: Tue, 6 Feb 2007 17:05:00 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [Libhugetlbfs-devel] Hugepages_Rsvd goes huge in 2.6.20-rc7
Message-ID: <20070207010500.GB7580@us.ibm.com>
References: <20070206001903.GP7953@us.ibm.com> <20070206002534.GQ7953@us.ibm.com> <20070206005547.GA5071@us.ibm.com> <20070206012442.GD20123@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070206012442.GD20123@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On 06.02.2007 [12:24:42 +1100], David Gibson wrote:
> On Mon, Feb 05, 2007 at 04:55:47PM -0800, Nishanth Aravamudan wrote:
> > On 05.02.2007 [16:25:34 -0800], Nishanth Aravamudan wrote:
> > > Sorry, I botched Hugh's e-mail address, please make sure to reply to the
> > > correct one.
> > > 
> > > Thanks,
> > > Nish
> > > 
> > > On 05.02.2007 [16:19:04 -0800], Nishanth Aravamudan wrote:
> > > > Hi all,
> > > > 
> > > > So, here's the current state of the hugepages portion of my
> > > > /proc/meminfo (x86_64, 2.6.20-rc7, will test with 2.6.20
> > > > shortly, but AFAICS, there haven't been many changes to hugepage
> > > > code between the two):
> > 
> > Reproduced on 2.6.20, and I think I've got a means to make it more
> > easily reproducible (at least on x86_64).
<snip>
> > Also note, that I'm not trying to defend the way I'm approaching
> > this problem in libhugetlbfs (I'm very open to alternatives) -- but
> > regardless of what I do there, I don't think Rsvd should be
> > 18446744073709551615 ...
> 
> Oh, certainly not.  Clearly we're managing to decrement it more times
> than we're incrementing it somehow.  I'd check the codepath for the
> madvise() thing, we may not be handling that properly.

FYI, Ken Chen's patch fixes the problem for me:

http://marc2.theaimsgroup.com/?l=linux-mm&m=117079608820399&w=2

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
