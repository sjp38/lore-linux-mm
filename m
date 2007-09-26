Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8Q3HScC027204
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 13:17:28 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8Q3L1jO211318
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 13:21:02 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8Q3Fv0Q000628
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 13:15:57 +1000
Message-ID: <46F9CF29.9000604@linux.vnet.ibm.com>
Date: Wed, 26 Sep 2007 08:46:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH] memory controller statistics
References: <46E12020.1060203@linux.vnet.ibm.com> <20070926014843.161E61BFA33@siro.lan>
In-Reply-To: <20070926014843.161E61BFA33@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: containers@lists.osdl.org, minoura@valinux.co.jp, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> YAMAMOTO Takashi wrote:
>>> hi,
>>>
>>> i implemented some statistics for your memory controller.
>>>
>>> it's tested with 2.6.23-rc2-mm2 + memory controller v7.
>>> i think it can be applied to 2.6.23-rc4-mm1 as well.
>>>
>> Thanks for doing this. We are building containerstats for
>> per container statistics. It would be really nice to provide
>> the statistics using that interface. I am not opposed to
>> memory.stat, but Paul Menage recommends that one file has
>> just one meaningful value.
>>
>> The other thing is that could you please report all the
>> statistics in bytes, we are moving to that interface,
>> I've posted patches to do that. If we are going to push
>> a bunch of statistics in one file, please use a format
>> separator like
>>
>> name: value
> 
> i followed /proc/vmstat.
> are you going to convert /proc/vmstat to the format as well?
> 

I see, no I don't plan to convert /proc/vmstat. I wanted
to make it easier for tools to parse the format. Like
you point out /proc/vmstat uses that format, so I guess
this format is just fine.

Thanks for following up.


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
