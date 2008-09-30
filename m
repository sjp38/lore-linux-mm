Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id m8UFkVaZ001711
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 15:46:32 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8UFkVhn3309820
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 16:46:31 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8UFkUaq016917
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 16:46:31 +0100
Message-ID: <48E249D2.2060805@fr.ibm.com>
Date: Tue, 30 Sep 2008 17:46:26 +0200
From: Daniel Lezcano <dlezcano@fr.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/30] Swap over NFS -v18
References: <20080724140042.408642539@chello.nl> <1222778476.9044.1.camel@twins>
In-Reply-To: <1222778476.9044.1.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
>> Latest version of the swap over nfs work.
>>
>> Patches are against: v2.6.26-rc8-mm1
>>
>> I still need to write some more comments in the reservation code.
>>
>> Pekka, it uses ksize(), please have a look.
>>
>> This version also deals with network namespaces.
>> Two things where I could do with some suggestsion:
>>
>>   - currently the sysctl code uses current->nrproxy.net_ns to obtain
>>     the current network namespace
>>
>>   - the ipv6 route cache code has some initialization order issues
> 
> Daniel, have you ever found time to look at my namespace issues?

Oops, no. I was busy and I forgot, sorry.
Let me review the sysctl vs namespace part.

Thanks
   -- Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
