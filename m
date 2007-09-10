Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8A8R4Vp030158
	for <linux-mm@kvack.org>; Mon, 10 Sep 2007 18:27:04 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8A8UZva188084
	for <linux-mm@kvack.org>; Mon, 10 Sep 2007 18:30:36 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8A9R06w018005
	for <linux-mm@kvack.org>; Mon, 10 Sep 2007 19:27:01 +1000
Message-ID: <46E4FFD1.4010708@linux.vnet.ibm.com>
Date: Mon, 10 Sep 2007 13:56:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH] memory controller statistics
References: <20070907033942.4A6541BFA52@siro.lan> <46E12020.1060203@linux.vnet.ibm.com> <kk5tzq39x7h.fsf@brer.local.valinux.co.jp>
In-Reply-To: <kk5tzq39x7h.fsf@brer.local.valinux.co.jp>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?566V5rWm55yf?= <minoura@valinux.co.jp>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, containers@lists.osdl.org, Paul Menage <menage@google.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

=?ISO-8859-1?Q?=E7=AE=95=E6=B5=A6=E7=9C=9F?= wrote:
Return-Path: <owner-linux-mm@kvack.org>
X-Envelope-To: <"|/home/majordomo/wrapper archive -f /home/ftp/pub/archives/linux-mm/linux-mm -m -a"> (uid 0)
X-Orcpt: rfc822;linux-mm-outgoing
Original-Recipient: rfc822;linux-mm-outgoing

> Takashi is AFK for a while; i'm replying for him as possible.
> 
>> Thanks for doing this. We are building containerstats for
>> per container statistics. It would be really nice to provide
>> the statistics using that interface. I am not opposed to
>> memory.stat, but Paul Menage recommends that one file has
>> just one meaningful value.
> 
> Thanks, we'll check it.  The interface is not important for
> us.
> 
>> The other thing is that could you please report all the
>> statistics in bytes, we are moving to that interface,
>> I've posted patches to do that. If we are going to push
>> a bunch of statistics in one file, please use a format
>> separator like
> 
>> name: value
> 
>>> YAMOMOTO Takshi
>>>
>>> todo: something like nr_active/inactive in /proc/vmstat.
>>>
> 
>> This would be really nice to add.
> 
> `something' here could be # of pages (in bytes according to
> your advice) on the global active (or inactive) list that
> are charged to a container, and/or # of pages on the
> per-container active/inactive list.  The latter is easy to
> implement but I'm afraid it's somewhat confusing for users.
> 

I think it would be useful for administrators to get a rough
idea of the working set (active bytes), to configure the size
of the container.

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
