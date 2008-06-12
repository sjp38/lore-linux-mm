Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5C1Bpkd012104
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 21:11:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5C1Bpgg127588
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 19:11:51 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5C1Bp36031510
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 19:11:51 -0600
Date: Wed, 11 Jun 2008 19:11:49 -0600
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 05/21] hugetlb: new sysfs interface
Message-ID: <20080612011149.GA21542@us.ibm.com>
References: <20080604112939.789444496@amd.local0.net> <20080604113111.647714612@amd.local0.net> <20080608115941.746732a5.akpm@linux-foundation.org> <20080610030234.GE19404@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080610030234.GE19404@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Greg KH <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On 10.06.2008 [05:02:34 +0200], Nick Piggin wrote:
> On Sun, Jun 08, 2008 at 11:59:41AM -0700, Andrew Morton wrote:
> > On Wed, 04 Jun 2008 21:29:44 +1000 npiggin@suse.de wrote:
> > 
> > > Provide new hugepages user APIs that are more suited to multiple hstates in
> > > sysfs. There is a new directory, /sys/kernel/hugepages. Underneath that
> > > directory there will be a directory per-supported hugepage size, e.g.:
> > > 
> > > /sys/kernel/hugepages/hugepages-64kB
> > > /sys/kernel/hugepages/hugepages-16384kB
> > > /sys/kernel/hugepages/hugepages-16777216kB
> > 
> > Maybe /sys/mm or /sys/vm would be a more appropriate place.
> 
> I'm thinking all the random kernel subsystems under /sys/ should
> rather be moved to /sys/kernel/. Imagine how much crap will be
> under the root directory if every kernel subsystem goes there.
> 
> The system is the kernel, afterall, the subsystems should be under
> there (arguably /sys/kernel/mm/hugepages/ would be better again, in
> fact yes Nish can we do that?).

It should be pretty easy. Just need to allocate and add an appropriate
kobject like kernel_kobj somewhere in the main vm initialization path
and then change the parent in my patch to be that one rather than
kernel_kobj.

I won't have a chance to do this for a few weeks, though :/

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
