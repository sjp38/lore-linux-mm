Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD2576B00A1
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 23:12:34 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o9C3CWss021617
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 20:12:33 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by kpbe19.cbf.corp.google.com with ESMTP id o9C3CUkX008200
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 20:12:31 -0700
Received: by pwj9 with SMTP id 9so477297pwj.20
        for <linux-mm@kvack.org>; Mon, 11 Oct 2010 20:12:30 -0700 (PDT)
Date: Mon, 11 Oct 2010 20:12:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <20101012111451.AD2E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1010112004260.2066@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1010081255010.32749@router.home> <alpine.DEB.2.00.1010111907190.27825@chino.kir.corp.google.com> <20101012111451.AD2E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2010, KOSAKI Motohiro wrote:

> > It doesn't determine what the maximum latency to that memory is, it relies 
> > on whatever was defined in the SLIT; the only semantics of that distance 
> > comes from the ACPI spec that states those distances are relative to the 
> > local distance of 10.
> 
> Right. but do we need to consider fake SLIT case? I know actually such bogus
> slit are there. but I haven't seen such fake SLIT made serious trouble.
> 

If we can make the assumption that the SLIT entries are truly 
representative of the latencies and are adhering to the semantics 
presented in the ACPI spec, then this means the VM prefers to do zone 
reclaim rather than from other nodes when the latter is 3x more costly.

That's fine by me, as I've mentioned we've done this for a couple years 
because we've had to explicitly disable zone_reclaim_mode for such 
configurations.  If that's the policy decision that's been made, though, 
we _could_ measure the cost at boot and set zone_reclaim_mode depending on 
the measured latency rather than relying on the SLIT at all in this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
