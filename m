Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CD0B86B00B4
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 02:41:15 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9C6d6L0021230
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 00:39:06 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9C6fDE2204332
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 00:41:13 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9C6fDni031314
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 00:41:13 -0600
Date: Tue, 12 Oct 2010 12:11:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
Message-ID: <20101012064108.GE25875@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101012111451.AD2E.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1010112004260.2066@chino.kir.corp.google.com>
 <20101012130806.AD37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101012130806.AD37.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-10-12 13:07:35]:

> > On Tue, 12 Oct 2010, KOSAKI Motohiro wrote:
> > 
> > > > It doesn't determine what the maximum latency to that memory is, it relies 
> > > > on whatever was defined in the SLIT; the only semantics of that distance 
> > > > comes from the ACPI spec that states those distances are relative to the 
> > > > local distance of 10.
> > > 
> > > Right. but do we need to consider fake SLIT case? I know actually such bogus
> > > slit are there. but I haven't seen such fake SLIT made serious trouble.
> > > 
> > 
> > If we can make the assumption that the SLIT entries are truly 
> > representative of the latencies and are adhering to the semantics 
> > presented in the ACPI spec, then this means the VM prefers to do zone 
> > reclaim rather than from other nodes when the latter is 3x more costly.
> > 
> > That's fine by me, as I've mentioned we've done this for a couple years 
> > because we've had to explicitly disable zone_reclaim_mode for such 
> > configurations.  If that's the policy decision that's been made, though, 
> > we _could_ measure the cost at boot and set zone_reclaim_mode depending on 
> > the measured latency rather than relying on the SLIT at all in this case.
> 
> ok, got it. thanks.
>

Could we please document the change and help people understand why
with newer kernels they may see the value of zone_reclaim_mode change
on their systems and how to set it back if required. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
