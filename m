Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 142046B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 02:12:42 -0400 (EDT)
Message-ID: <4EAA4799.1020505@cn.fujitsu.com>
Date: Fri, 28 Oct 2011 14:11:37 +0800
From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Reply-To: gaowanlong@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [possible deadlock][3.1.0-g138c4ae] possible circular locking
 dependency detected
References: <4EAA2492.3020907@cn.fujitsu.com>	<CAA_GA1eGt-Xu1wQ-g0v+J7CD4OEAU1nm1Eviww1+mOKjYWEcMg@mail.gmail.com>	<4EAA4263.2090809@cn.fujitsu.com> <CAA_GA1cKK45Z=YFUHRi-LUuhWpcs9ruW9xom_6LRmqhRNao+hQ@mail.gmail.com>
In-Reply-To: <CAA_GA1cKK45Z=YFUHRi-LUuhWpcs9ruW9xom_6LRmqhRNao+hQ@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On 10/28/2011 02:02 PM, Bob Liu wrote:


>>
>>
>> Oh, it looks like can fix this bug, but I also can't reproduce it whether with or without this patch.
>>
> 
> Make sure CONFIG_DEBUG_LOCK_ALLOC was set.
> 


Yeah, certainly, if not, the dmesg can't appear anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
