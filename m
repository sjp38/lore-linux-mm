Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBELeBDr348814
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 16:40:11 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBELeAYB422912
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 14:40:10 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBELeAaJ028521
	for <linux-mm@kvack.org>; Tue, 14 Dec 2004 14:40:10 -0700
Date: Tue, 14 Dec 2004 12:10:57 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <19950000.1103055057@flay>
In-Reply-To: <Pine.SGI.4.61.0412141319100.22462@kzerza.americas.sgi.com>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com><9250000.1103050790@flay> <Pine.SGI.4.61.0412141319100.22462@kzerza.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

>> Yup, makes a lot of sense to me to stripe these, for the caches that
>> are global (ie inodes, dentries, etc).  Only question I'd have is 
>> didn't Manfred or someone (Andi?) do this before? Or did that never
>> get accepted? I know we talked about it a while back.
> 
> Are you thinking of the 2006-06-05 patch from Andi about using
> the NUMA policy API for boot time allocation?
> 
> If so, that patch was accepted, but affects neither allocations
> performed via alloc_bootmem nor __get_free_pages, which are
> currently used to allocate these hashes.  vmalloc, however, does
> behave as desired with Andi's patch.

Nope, was for the hashes, but I think maybe it was all vapourware.
 
> Which is why vmalloc was chosen to solve this problem.  There were
> other more complicated possible solutions (e.g. multi-level hash tables,
> with the bottommost/largest level being allocated across all nodes),
> however those would have been so intrusive as to be unpalatable.
> So the vmalloc solution seemed reasonable, as long as it is used
> only on architectures with plentiful vmalloc space.

Yup, seems like a reasonable approach.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
