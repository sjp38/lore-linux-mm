Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1L6uZbC023316
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 12:26:35 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1L6uZRX897034
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 12:26:35 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1L6uYLC023642
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 06:56:34 GMT
Message-ID: <47BD1F97.8030202@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 12:22:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <18364.16552.455371.242369@stoffel.org> <47BC4554.10304@linux.vnet.ibm.com> <Pine.LNX.4.64.0802201647060.26109@fbirervta.pbzchgretzou.qr> <18364.20755.798295.881259@stoffel.org> <47BC5211.6030102@linux.vnet.ibm.com> <20080221154916.723fed49.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080221154916.723fed49.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: John Stoffel <john@stoffel.org>, Jan Engelhardt <jengelh@computergmbh.de>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 20 Feb 2008 21:45:13 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> But for computers, limits is an expected and understood term, and for
>>> filesystems it's quotas.  So in this case, I *still* think you should
>>> be using the term "Memory Quota Controller" instead.  It just makes it
>>> clearer to a larger audience what you mean.
>>>
>> Memory Quota sounds very confusing to me. Usually a quota implies limits, but in
>> a true framework, one can also implement guarantees and shares.
>>
> This "cgroup memory contoller" is called as "Memory Resource Contoller"
> in my office ;)
> 
> How about Memory Resouce Contoller ?

That is a good name and believe me or not I was thinking of the same name.

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
