Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DEFF26B009E
	for <linux-mm@kvack.org>; Mon, 11 Oct 2010 22:17:08 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C2H6ri004931
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Oct 2010 11:17:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 516E745DE50
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 11:17:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2229645DE54
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 11:17:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B9511DB8038
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 11:17:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC3A31DB8042
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 11:17:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <alpine.DEB.2.00.1010111907190.27825@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1010081255010.32749@router.home> <alpine.DEB.2.00.1010111907190.27825@chino.kir.corp.google.com>
Message-Id: <20101012111451.AD2E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Oct 2010 11:17:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 8 Oct 2010, Christoph Lameter wrote:
> 
> > It implies that zone reclaim is going to be automatically enabled if the
> > maximum latency to the memory farthest away is 3 times or more that of a
> > local memory access.
> > 
> 
> It doesn't determine what the maximum latency to that memory is, it relies 
> on whatever was defined in the SLIT; the only semantics of that distance 
> comes from the ACPI spec that states those distances are relative to the 
> local distance of 10.

Right. but do we need to consider fake SLIT case? I know actually such bogus
slit are there. but I haven't seen such fake SLIT made serious trouble.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
