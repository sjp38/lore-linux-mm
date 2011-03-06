Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D12818D0039
	for <linux-mm@kvack.org>; Sun,  6 Mar 2011 18:44:59 -0500 (EST)
Message-ID: <4D741C46.70702@zytor.com>
Date: Sun, 06 Mar 2011 15:44:06 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memblock: Properly handle overlaps and fix error path
References: <1299453678.8833.969.camel@pasglop> <4D741890.7000607@kernel.org>
In-Reply-To: <4D741890.7000607@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Russell King <linux@arm.linux.org.uk>, David Miller <davem@davemloft.net>

On 03/06/2011 03:28 PM, Yinghai Lu wrote:
>>  
>> -	rgnbegin = rgnend = 0; /* supress gcc warnings */
>> -From 1f75ea7782bd83f6402964d3b9889ccd69484e02 Mon Sep 17 00:00:00 2001
>> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> Date: Mon, 7 Mar 2011 10:18:38 +1100
>> Subject: 
> 
> you put two patches in one mail?
> 

And you quoted the entire email, including both patches, in its entirety
to say that?

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
