Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 028C66B006A
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 12:59:42 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o98Gn6WB002931
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 10:49:06 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o98GxZE8094350
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 10:59:36 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o98GxXWd018900
	for <linux-mm@kvack.org>; Fri, 8 Oct 2010 10:59:35 -0600
Date: Fri, 8 Oct 2010 22:29:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
Message-ID: <20101008165930.GH5327@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101008104852.803E.A69D9226@jp.fujitsu.com>
 <20101008090427.GB5327@balbir.in.ibm.com>
 <alpine.DEB.2.00.1010081044530.30029@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010081044530.30029@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

* Christoph Lameter <cl@linux.com> [2010-10-08 10:45:16]:

> On Fri, 8 Oct 2010, Balbir Singh wrote:
> 
> > I am not sure if this makes sense, since RECLAIM_DISTANCE is supposed
> > to be a hardware parameter. Could you please help clarify what the
> > access latency of a node with RECLAIM_DISTANCE 20 to that of a node
> > with RECLAIM_DISTANCE 30 is? Has the hardware definition of reclaim
> > distance changed?
> 
> 10 is the local distance. So 30 should be 3x the latency that a local
> access takes.
>

Does this patch then imply that we should do zone_reclaim only for 3x
nodes and not 2x nodes as we did earlier.
 
> > I suspect the side effect is the zone_reclaim_mode is not set to 1 on
> > bootup for the 2-4 socket machines you mention, which results in
> > better VM behaviour?
> 
> Right.
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
