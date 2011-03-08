Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9658D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 21:43:39 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B9DBB3EE0AE
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:43:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2D3D45DE59
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:43:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A3D045DE56
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:43:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C7051DB8048
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:43:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 452131DB803A
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:43:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
In-Reply-To: <20110307163513.GC13384@alboin.amr.corp.intel.com>
References: <20110307172609.8A01.A69D9226@jp.fujitsu.com> <20110307163513.GC13384@alboin.amr.corp.intel.com>
Message-Id: <20110308114159.7EAD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Mar 2011 11:43:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> > Don't we need to make per zone stastics? I'm afraid small dma zone 
> > makes much thp-splitting and screw up this stastics.
> 
> Does it? I haven't seen that so far.
> 
> If it happens a lot it would be better to disable THP for the 16MB DMA
> zone at least. Or did you mean the 4GB zone?

I assumered 4GB. And cpusets/mempolicy binding might makes similar 
issue. It can make only one zone high pressure.

But, hmmm...
Do you mean you don't hit any issue then? I don't think do don't tested
NUMA machine. So, it has  no practical problem I can agree this.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
