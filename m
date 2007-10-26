Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9QHIni4001562
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 13:18:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9QHInaV125376
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 13:18:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9QHImSo004920
	for <linux-mm@kvack.org>; Fri, 26 Oct 2007 13:18:49 -0400
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071026161406.GB19443@skynet.ie>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
	 <1193331162.4039.141.camel@localhost>
	 <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
	 <1193332528.4039.156.camel@localhost>
	 <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
	 <20071025180514.GB20345@skynet.ie> <1193335935.24087.22.camel@localhost>
	 <20071026095043.GA14347@skynet.ie> <1193413936.24087.91.camel@localhost>
	 <20071026161406.GB19443@skynet.ie>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 10:18:46 -0700
Message-Id: <1193419126.24087.130.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 17:14 +0100, Mel Gorman wrote:
> 
> I would think that if memory is being shrunk in the system, the monitoring
> software would not particularly care. If you think that might be the case,
> then rename mem_removable to mem_removable_score and have it print out 0 or
> 1 for the moment based on the current criteria. Tell userspace developers
> that the higher the score, the more suitable it is for removing.  That will
> allow the introduction of a proper scoring mechanism later if there is a
> good reason for it without breaking backwards compatability. 

I completely agree.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
