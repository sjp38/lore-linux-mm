Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1N9LCHw023140
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 14:51:12 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1N9LB1c934022
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 14:51:12 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1N9LGoB001469
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 09:21:16 GMT
Message-ID: <47BFE468.70104@linux.vnet.ibm.com>
Date: Sat, 23 Feb 2008 14:46:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
References: <20080221203518.544461000@menage.corp.google.com> <20080221205525.349180000@menage.corp.google.com> <47BE4FB5.5040902@linux.vnet.ibm.com> <20080223000426.adf5c75a.akpm@linux-foundation.org>
In-Reply-To: <20080223000426.adf5c75a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: menage@google.com, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 22 Feb 2008 09:59:41 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> menage@google.com wrote:
>>> Update the memory controller to use read_uint for its
>>> limit/usage/failcnt control files, calling the new
>>> res_counter_read_uint() function.
>>>
>>> Signed-off-by: Paul Menage <menage@google.com>
>>>
>> Hi, Paul,
>>
>> Looks good, except for the name uint(), can we make it u64(). Integers are 32
>> bit on both ILP32 and LP64, but we really read/write 64 bit values.
>>
> 
> yup, I agree.  Even though I don't know what ILP32 and LP64 are ;)

ILP32 and LP64 are programming models. They stand for Integer, Long, Pointer 32
bit for 32 bit systems and Long, Pointer 64 bit for 64 bit systems (which
implies integers are 32 bit).

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
