Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8HKmVdm030545
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:48:31 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HKmG9u3858668
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:48:16 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HKmFGs007938
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 06:48:16 +1000
Message-ID: <46EEE80D.6060808@linux.vnet.ibm.com>
Date: Tue, 18 Sep 2007 02:18:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Configurable reclaim batch size
References: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com> <1189812002.5826.31.camel@lappy> <Pine.LNX.4.64.0709171053040.26860@schroedinger.engr.sgi.com> <20070917215615.685a5378@lappy>
In-Reply-To: <20070917215615.685a5378@lappy>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Mon, 17 Sep 2007 10:54:59 -0700 (PDT) Christoph Lameter
> <clameter@sgi.com> wrote:
> 
>> On Sat, 15 Sep 2007, Peter Zijlstra wrote:
>>
>>> It increases the lock hold times though. Otoh it might work out with the
>>> lock placement.
>> Yeah may be good for NUMA.
> 
> Might, I'd just like a _little_ justification for an extra tunable.
> 
>>> Do you have any numbers that show this is worthwhile?
>> Tried to run AIM7 but the improvements are in the noise. I need a tests 
>> that really does large memory allocation and stresses the LRU. I could 
>> code something up but then Lee's patch addresses some of the same issues.
>> Is there any standard test that shows LRU handling regressions?
> 
> hehe, I wish. I was just hoping you'd done this patch as a result of an
> actual problem and not a hunch.

Please do let me know if someone finds a good standard test for it or a
way to stress reclaim. I've heard AIM7 come up often, but never been
able to push it much. I should retry.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
