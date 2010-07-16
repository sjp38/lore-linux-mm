Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5EBE26B02A3
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 04:23:37 -0400 (EDT)
Message-ID: <4C4016FD.9080207@cs.helsinki.fi>
Date: Fri, 16 Jul 2010 11:23:25 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
References: <20100709190706.938177313@quilx.com> <alpine.DEB.2.00.1007141650110.29110@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1007141650110.29110@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Fri, 9 Jul 2010, Christoph Lameter wrote:
> 
>> The following patchset cleans some pieces up and then equips SLUB with
>> per cpu queues that work similar to SLABs queues.
> 
> Pekka, I think patches 4-8 could be applied to your tree now, they're 
> relatively unchanged from what's been posted before.  (I didn't ack patch 
> 9 because I think it makes slab_lock() -> slab_unlock() matching more 
> difficult with little win, but I don't feel strongly about it.)

Yup, I applied 4-8. Thanks guys!

> I'd also consider patch 7 for 2.6.35-rc6 (and -stable).

It's an obvious bug fix but is it triggered in practice? Is there a 
bugzilla report for that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
