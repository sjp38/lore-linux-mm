Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD52EC00307
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D8E32082C
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:53:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D8E32082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1186F6B0006; Fri,  6 Sep 2019 08:53:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CA796B0007; Fri,  6 Sep 2019 08:53:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFA786B0008; Fri,  6 Sep 2019 08:53:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id CDA466B0006
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:53:22 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6638C2DFD
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:53:22 +0000 (UTC)
X-FDA: 75904486644.07.bulb99_3a7b080258562
X-HE-Tag: bulb99_3a7b080258562
X-Filterd-Recvd-Size: 11834
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:53:21 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 50914883820;
	Fri,  6 Sep 2019 12:53:20 +0000 (UTC)
Received: from [10.36.117.162] (ovpn-117-162.ams2.redhat.com [10.36.117.162])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CF36E60BF1;
	Fri,  6 Sep 2019 12:53:13 +0000 (UTC)
Subject: Re: [PATCH v2 3/7] mm: Introduce FAULT_FLAG_INTERRUPTIBLE
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
 Jerome Glisse <jglisse@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>,
 Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 Denis Plotnikov <dplotnikov@virtuozzo.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman
 <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>,
 "Dr . David Alan Gilbert" <dgilbert@redhat.com>
References: <20190905101534.9637-1-peterx@redhat.com>
 <20190905101534.9637-4-peterx@redhat.com>
 <0d45ffaf-0588-a068-d361-6a9cb6c71413@redhat.com>
 <20190906123851.GB8813@xz-x1>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <df8cc623-617f-f14f-d23e-312dbdf05d2e@redhat.com>
Date: Fri, 6 Sep 2019 14:53:13 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190906123851.GB8813@xz-x1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (mx1.redhat.com [10.5.110.69]); Fri, 06 Sep 2019 12:53:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.09.19 14:38, Peter Xu wrote:
> On Fri, Sep 06, 2019 at 11:02:22AM +0200, David Hildenbrand wrote:
>> On 05.09.19 12:15, Peter Xu wrote:
>>> handle_userfaultfd() is currently the only one place in the kernel
>>> page fault procedures that can respond to non-fatal userspace signals.
>>> It was trying to detect such an allowance by checking against USER &
>>> KILLABLE flags, which was "un-official".
>>>
>>> In this patch, we introduced a new flag (FAULT_FLAG_INTERRUPTIBLE) to
>>> show that the fault handler allows the fault procedure to respond even
>>> to non-fatal signals.  Meanwhile, add this new flag to the default
>>> fault flags so that all the page fault handlers can benefit from the
>>> new flag.  With that, replacing the userfault check to this one.
>>>
>>> Since the line is getting even longer, clean up the fault flags a bit
>>> too to ease TTY users.
>>>
>>> Although we've got a new flag and applied it, we shouldn't have any
>>> functional change with this patch so far.
>>>
>>> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
>>> Signed-off-by: Peter Xu <peterx@redhat.com>
>>> ---
>>>  fs/userfaultfd.c   |  4 +---
>>>  include/linux/mm.h | 39 ++++++++++++++++++++++++++++-----------
>>>  2 files changed, 29 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
>>> index ccbdbd62f0d8..4a8ad2dc2b6f 100644
>>> --- a/fs/userfaultfd.c
>>> +++ b/fs/userfaultfd.c
>>> @@ -462,9 +462,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
>>>  	uwq.ctx = ctx;
>>>  	uwq.waken = false;
>>>  
>>> -	return_to_userland =
>>> -		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
>>> -		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
>>> +	return_to_userland = vmf->flags & FAULT_FLAG_INTERRUPTIBLE;
>>>  	blocking_state = return_to_userland ? TASK_INTERRUPTIBLE :
>>>  			 TASK_KILLABLE;
>>>  
>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>> index 57fb5c535f8e..53ec7abb8472 100644
>>> --- a/include/linux/mm.h
>>> +++ b/include/linux/mm.h
>>> @@ -383,22 +383,38 @@ extern unsigned int kobjsize(const void *objp);
>>>   */
>>>  extern pgprot_t protection_map[16];
>>>  
>>> -#define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
>>> -#define FAULT_FLAG_MKWRITE	0x02	/* Fault was mkwrite of existing pte */
>>> -#define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
>>> -#define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
>>> -#define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
>>> -#define FAULT_FLAG_TRIED	0x20	/* Second try */
>>> -#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
>>> -#define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
>>> -#define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
>>> +/**
>>> + * Fault flag definitions.
>>> + *
>>> + * @FAULT_FLAG_WRITE: Fault was a write fault.
>>> + * @FAULT_FLAG_MKWRITE: Fault was mkwrite of existing PTE.
>>> + * @FAULT_FLAG_ALLOW_RETRY: Allow to retry the fault if blocked.
>>> + * @FAULT_FLAG_RETRY_NOWAIT: Don't drop mmap_sem and wait when retrying.
>>> + * @FAULT_FLAG_KILLABLE: The fault task is in SIGKILL killable region.
>>> + * @FAULT_FLAG_TRIED: The fault has been tried once.
>>> + * @FAULT_FLAG_USER: The fault originated in userspace.
>>> + * @FAULT_FLAG_REMOTE: The fault is not for current task/mm.
>>> + * @FAULT_FLAG_INSTRUCTION: The fault was during an instruction fetch.
>>> + * @FAULT_FLAG_INTERRUPTIBLE: The fault can be interrupted by non-fatal signals.
>>> + */
>>> +#define FAULT_FLAG_WRITE			0x01
>>> +#define FAULT_FLAG_MKWRITE			0x02
>>> +#define FAULT_FLAG_ALLOW_RETRY			0x04
>>> +#define FAULT_FLAG_RETRY_NOWAIT			0x08
>>> +#define FAULT_FLAG_KILLABLE			0x10
>>> +#define FAULT_FLAG_TRIED			0x20
>>> +#define FAULT_FLAG_USER				0x40
>>> +#define FAULT_FLAG_REMOTE			0x80
>>> +#define FAULT_FLAG_INSTRUCTION  		0x100
>>> +#define FAULT_FLAG_INTERRUPTIBLE		0x200
>>>  
>>
>> I'd probably split off the unrelated doc changes. Just a matter of taste.
> 
> The thing is that it's not really a document change but only a format
> change (when I wanted to add the new macro it's easily getting out of
> 80 chars so I simply reformatted all the rest to make them look
> similar).  I'm afraid that could be too trivial to change the format
> as a single patch, but I can do it if anyone else also thinks it
> proper.
> 
>>
>>>  /*
>>>   * The default fault flags that should be used by most of the
>>>   * arch-specific page fault handlers.
>>>   */
>>>  #define FAULT_FLAG_DEFAULT  (FAULT_FLAG_ALLOW_RETRY | \
>>> -			     FAULT_FLAG_KILLABLE)
>>> +			     FAULT_FLAG_KILLABLE | \
>>> +			     FAULT_FLAG_INTERRUPTIBLE)
>>
>> So by default, all faults are marked interruptible, also
>> !FAULT_FLAG_USER. I assume the trick right now is that
>> handle_userfault() will indeed only be called on user faults and the
>> flag is used nowhere else ;)
> 
> Sorry if this is confusing, but FAULT_FLAG_DEFAULT is just a macro to
> make the patchset easier so we define this initial flags for most of
> the archs (say, there can be some arch that does not use this default
> value, but the fact is most archs are indeed using the same flags
> hence we define it here now).
> 
> And, userfaultfd can also handle kernel faults.  For FAULT_FLAG_USER,
> it will be set if the fault comes from userspace (in
> do_user_addr_fault()).
> 
Got it, sounds sane to me then.

>>
>> Would it make sense to name it FAULT_FLAG_USER_INTERRUPTIBLE, to stress
>> that the flag only applies to user faults? (or am I missing something
>> and this could also apply to !user faults somewhen in the future?
> 
> As mentioned above, uffd can handle kernel faults.  And, for what I
> understand, it's not really directly related to user fault or not at
> all, instead its more or less match with TASK_{INTERRUPTIBLE|KILLABLE}
> on what kind of signals we care about during the fault processing.  So
> it seems to me that it's two different things.
> 
>>
>> (I am no expert on the fault paths yet, so sorry for the silly questions)
> 
> (I only hope that I'm not providing silly answers. :)

I highly doubt it :) Thanks!

-- 

Thanks,

David / dhildenb

