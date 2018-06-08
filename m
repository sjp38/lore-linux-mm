Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24D686B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 08:57:10 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 5-v6so12997630qke.19
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 05:57:10 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n64-v6si2069126qkf.210.2018.06.08.05.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 05:57:09 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
 <20180604190229.GB10088@ram.oc3035372033.ibm.com>
 <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
 <20180608023441.GA5573@ram.oc3035372033.ibm.com>
 <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
 <20180608121551.3c151e0c@naga.suse.cz>
 <aa136e1e-3bf2-fd92-2eab-16469c467729@redhat.com>
 <20180608145413.393fa245@kitsune.suse.cz>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <f440aaa4-0a55-3ccd-2df1-2ad595e9e17a@redhat.com>
Date: Fri, 8 Jun 2018 14:57:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180608145413.393fa245@kitsune.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Michal_Such=c3=a1nek?= <msuchanek@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Ram Pai <linuxram@us.ibm.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On 06/08/2018 02:54 PM, Michal SuchA!nek wrote:
> On Fri, 8 Jun 2018 12:44:53 +0200
> Florian Weimer <fweimer@redhat.com> wrote:
> 
>> On 06/08/2018 12:15 PM, Michal SuchA!nek wrote:
>>> On Fri, 8 Jun 2018 07:53:51 +0200
>>> Florian Weimer <fweimer@redhat.com> wrote:
>>>    
>>>> On 06/08/2018 04:34 AM, Ram Pai wrote:
>>>>>>
>>>>>> So the remaining question at this point is whether the Intel
>>>>>> behavior (default-deny instead of default-allow) is preferable.
>>>>>
>>>>> Florian, remind me what behavior needs to fixed?
>>>>
>>>> See the other thread.  The Intel register equivalent to the AMR by
>>>> default disallows access to yet-unallocated keys, so that threads
>>>> which are created before key allocation do not magically gain
>>>> access to a key allocated by another thread.
>>>>   
>>>
>>> That does not make any sense. The threads share the address space so
>>> they should also share the keys.
>>>
>>> Or in other words the keys are supposed to be acceleration of
>>> mprotect() so if mprotect() magically gives access to threads that
>>> did not call it so should pkey functions. If they cannot do that
>>> then they fail the primary purpose.
>>
>> That's not how protection keys work.  The access rights are
>> thread-specific, so that you can change them locally, without
>> synchronization and expensive inter-node communication.
>>
> 
> And the association of a key with part of the address space is
> thread-local as well?

No, that part is still per-process.

Florian
