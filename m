Received: from austin.ibm.com (netmail1.austin.ibm.com [9.53.250.96])
	by mg03.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id KAA29028
	for <linux-mm@kvack.org>; Wed, 18 Jul 2001 10:08:25 -0500
Received: from baldur.austin.ibm.com (baldur.austin.ibm.com [9.53.216.148])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id KAA50680
	for <linux-mm@kvack.org>; Wed, 18 Jul 2001 10:07:55 -0500
Received: from baldur (localhost.austin.ibm.com [127.0.0.1])
        by localhost.austin.ibm.com (8.12.0.Beta12/8.12.0.Beta12/Debian 8.12.0.Beta12) with ESMTP id f6IF7tak030404
        for <linux-mm@kvack.org>; Wed, 18 Jul 2001 10:07:55 -0500
Date: Wed, 18 Jul 2001 10:07:55 -0500
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Re: [PATCH] Separate global/perzone inactive/free shortage
Message-ID: <12670000.995468875@baldur>
In-Reply-To: <Pine.LNX.4.33.0107180808470.724-100000@mikeg.weiden.de>
References: <Pine.LNX.4.33.0107180808470.724-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, July 18, 2001 10:54:52 +0200 Mike Galbraith 
<mikeg@wen-online.de> wrote:

> Possible solution:
>
> Effectively reserving the last ~meg (pick a number, scaled by ramsize
> would be better) of ZONE_DMA for real GFP_DMA allocations would cure
> Dirk's problem I bet, and also cure most of the others too, simply by
> ensuring that the ONLY thing that could unbalance that zone would be
> real GFP_DMA pressure.  That way, you'd only eat the incredible cost
> of balancing that zone when it really really had to be done.

Couldn't something similar to this be accomplished by tweaking the 
pages_{min,low,high} values to ZONE_DMA based on the total memory in the 
machine?  It seems to me if you have a large memory machine it'd be simple 
enough to set at least pages_high (and perhaps pages_low?) to a larger 
value.  If we do this, won't it keep the DMA zone from triggering memory 
pressure as much?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmc@austin.ibm.com                                      T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
