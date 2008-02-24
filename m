Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1O2raVw030217
	for <linux-mm@kvack.org>; Sun, 24 Feb 2008 13:53:36 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1O2uPDl288422
	for <linux-mm@kvack.org>; Sun, 24 Feb 2008 13:56:26 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1O2qlwN024565
	for <linux-mm@kvack.org>; Sun, 24 Feb 2008 13:52:47 +1100
Message-ID: <47C0DAD8.8050401@linux.vnet.ibm.com>
Date: Sun, 24 Feb 2008 08:17:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
References: <20080221203518.544461000@menage.corp.google.com> <20080221205525.349180000@menage.corp.google.com> <47BE4FB5.5040902@linux.vnet.ibm.com> <6599ad830802230633i483c8dd1q5b541be1a92a5795@mail.gmail.com> <20080223105933.e6884808.akpm@linux-foundation.org>
In-Reply-To: <20080223105933.e6884808.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Sat, 23 Feb 2008 06:33:34 -0800 "Paul Menage" <menage@google.com> wrote:
> 
>> On Thu, Feb 21, 2008 at 8:29 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>  Looks good, except for the name uint(), can we make it u64(). Integers are 32
>>>  bit on both ILP32 and LP64, but we really read/write 64 bit values.
>> Yes, that's true. But read_uint() is more consistent with all the
>> other instances in cgroups and subsystems. So if we were to call it
>> res_counter_read_u64() I'd also want to rename all the other
>> *read_uint functions/fields to *read_u64 too. Can I do that in a
>> separate patch?
>>
> 
> Sounds sensible to me.
> 

Sure, fair enough.

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
