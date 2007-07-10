Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6AFh7XC1863698
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 01:43:08 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6AFjiHp141742
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 01:45:45 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6AFgBFE016060
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 01:42:12 +1000
Message-ID: <4693A8CD.7080808@linux.vnet.ibm.com>
Date: Tue, 10 Jul 2007 21:12:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 4/8] Memory controller memory accounting (v2)
References: <661de9470707100141h779e75eev9c09fdb2dfd09b8b@mail.gmail.com> <20070710084427.3F74B1BF77E@siro.lan>
In-Reply-To: <20070710084427.3F74B1BF77E@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> On 7/10/07, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
>>> hi,
>>>
>>>> diff -puN mm/memory.c~mem-control-accounting mm/memory.c
>>>> --- linux-2.6.22-rc6/mm/memory.c~mem-control-accounting       2007-07-05 13:45:18.000000000 -0700
>>>> +++ linux-2.6.22-rc6-balbir/mm/memory.c       2007-07-05 13:45:18.000000000 -0700
>>>> @@ -1731,6 +1736,9 @@ gotten:
>>>>               cow_user_page(new_page, old_page, address, vma);
>>>>       }
>>>>
>>>> +     if (mem_container_charge(new_page, mm))
>>>> +             goto oom;
>>>> +
>>>>       /*
>>>>        * Re-check the pte - we dropped the lock
>>>>        */
>>> it seems that the page will be leaked on error.
>> You mean meta_page right?
> 
> no.  i meant 'new_page'.
> 
> YAMAMOTO Takashi

Yes, I see. Thanks for clarifying.

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
