Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 3BD176B0036
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 10:11:30 -0400 (EDT)
Message-ID: <515C388C.5040903@profihost.ag>
Date: Wed, 03 Apr 2013 16:11:24 +0200
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
MIME-Version: 1.0
Subject: Re: NUMA Autobalancing Kernel 3.8
References: <515A87C3.1000309@profihost.ag> <20130402104844.GE32241@suse.de> <515AC3EE.1030803@profihost.ag> <20130402125408.GG32241@suse.de> <515AEC71.9020704@profihost.ag> <20130403140344.GA5811@suse.de>
In-Reply-To: <20130403140344.GA5811@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

Am 03.04.2013 16:03, schrieb Mel Gorman:
>> I've now tested 3.9-rc5 this gaves me a slightly different kernel log:
>> [  197.236518] pigz[2908]: segfault at 0 ip           (null) sp
>> 00007f347bffed00 error 14
>> [  197.237632] traps: pigz[2915] general protection ip:7f3482dbce2d
>> sp:7f3473ffec10 error:0 in libz.so.1.2.3.4[7f3482db7000+17000]
>> [  197.330615]  in pigz[400000+10000]
>>
>> With 3.8 it is the same as with 3.8.4 or 3.8.5.
>>
> 
> Ok. Are there NUMA machines were you do *not* see this problem?
Sadly no.

I can really fast reproduce it with this one:
1.) Machine with only 16GB Mem
2.) compressing two 60GB Files in parallel with pigz consuming all cores

> If so, can you spot what the common configuration, software or
hardware, that
> affects the broken machines versus the working machines? I'm wondering
> if there is a bug in a migration handler.
> 
> Do you know if a NUMA nodes are low on memory when the segfaults occur?
One of them is but the others aren't. (196GB Mem just 20GB in use)

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
