Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1642Qrj024145
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 15:02:26 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1646Cdj280194
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 15:06:13 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1642YJo010395
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 15:02:34 +1100
Message-ID: <47A930EC.9070009@linux.vnet.ibm.com>
Date: Wed, 06 Feb 2008 09:30:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] badness() dramatically overcounts memory
References: <1202252561.24634.64.camel@dogma.ljc.laika.com> <alpine.DEB.1.00.0802051507460.18347@chino.kir.corp.google.com> <20080206105041.2717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080206105041.2717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Jeff Davis <linux@j-davis.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
>>>> The interesting thing is the use of total_vm and not the RSS which is used as
>>>> the basis by the OOM killer. I need to read/understand the code a bit more.
>>> RSS makes more sense to me as well.
>> Andrea Arcangeli has patches pending which change this to the RSS.  
>> Specifically:
>>
>> 	http://marc.info/?l=linux-mm&m=119977937126925
> 
> I agreed with you that RSS is better :)
> 
> 
> 
> but..
> on many node numa, per zone rss is more better..

Do we have a per zone RSS per task? I don't remember seeing it.


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
