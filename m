Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CD7006B00AA
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 00:07:38 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9C47bJ2020405
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Oct 2010 13:07:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4A8D45DE70
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 13:07:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A97945DE6F
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 13:07:37 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF511DB803B
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 13:07:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AE5F1DB803A
	for <linux-mm@kvack.org>; Tue, 12 Oct 2010 13:07:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [resend][PATCH] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <alpine.DEB.2.00.1010112004260.2066@chino.kir.corp.google.com>
References: <20101012111451.AD2E.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010112004260.2066@chino.kir.corp.google.com>
Message-Id: <20101012130806.AD37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Oct 2010 13:07:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Rob Mueller <robm@fastmail.fm>, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 12 Oct 2010, KOSAKI Motohiro wrote:
> 
> > > It doesn't determine what the maximum latency to that memory is, it relies 
> > > on whatever was defined in the SLIT; the only semantics of that distance 
> > > comes from the ACPI spec that states those distances are relative to the 
> > > local distance of 10.
> > 
> > Right. but do we need to consider fake SLIT case? I know actually such bogus
> > slit are there. but I haven't seen such fake SLIT made serious trouble.
> > 
> 
> If we can make the assumption that the SLIT entries are truly 
> representative of the latencies and are adhering to the semantics 
> presented in the ACPI spec, then this means the VM prefers to do zone 
> reclaim rather than from other nodes when the latter is 3x more costly.
> 
> That's fine by me, as I've mentioned we've done this for a couple years 
> because we've had to explicitly disable zone_reclaim_mode for such 
> configurations.  If that's the policy decision that's been made, though, 
> we _could_ measure the cost at boot and set zone_reclaim_mode depending on 
> the measured latency rather than relying on the SLIT at all in this case.

ok, got it. thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
