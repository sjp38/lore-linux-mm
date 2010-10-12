Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 907166B009C
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 22:11:32 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o9C2BUSA008105
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 19:11:30 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by hpaq12.eem.corp.google.com with ESMTP id o9C2BSVt028160
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 19:11:29 -0700
Received: by pzk37 with SMTP id 37so45166pzk.9
        for <linux-mm@kvack.org>; Mon, 11 Oct 2010 19:11:28 -0700 (PDT)
Date: Mon, 11 Oct 2010 19:11:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <alpine.DEB.2.00.1010081255010.32749@router.home>
Message-ID: <alpine.DEB.2.00.1010111907190.27825@chino.kir.corp.google.com>
References: <20101008104852.803E.A69D9226@jp.fujitsu.com> <20101008090427.GB5327@balbir.in.ibm.com> <alpine.DEB.2.00.1010081044530.30029@router.home> <20101008165930.GH5327@balbir.in.ibm.com> <alpine.DEB.2.00.1010081255010.32749@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 8 Oct 2010, Christoph Lameter wrote:

> It implies that zone reclaim is going to be automatically enabled if the
> maximum latency to the memory farthest away is 3 times or more that of a
> local memory access.
> 

It doesn't determine what the maximum latency to that memory is, it relies 
on whatever was defined in the SLIT; the only semantics of that distance 
comes from the ACPI spec that states those distances are relative to the 
local distance of 10.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
