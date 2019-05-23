Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CA3DC282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 00:54:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C31BE2089E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 00:54:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="A4WEzCxS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C31BE2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 487FF6B0003; Wed, 22 May 2019 20:54:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4378A6B0006; Wed, 22 May 2019 20:54:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3277B6B0007; Wed, 22 May 2019 20:54:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 128AA6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 20:54:21 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q188so3803717ywc.15
        for <linux-mm@kvack.org>; Wed, 22 May 2019 17:54:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=OwzzXwM/wBQ9KUQhbTFgOHznyorW4zimbRGODpDav1M=;
        b=ez86o04I4AQs+XcRl9ontmmZwZi5B4+/KCJF+km8qWs0dcKh+Hb+vtC9/p07Y1XrXz
         dTKngr0PIUQwz+Uqgxxz9RilZPUIaFeFTXQZPXJbrwD6FLeqgsSAA/vWue8d9b9whinB
         Os+iAArOy8buxd7Q38jwCWwwhUxoeHU2DaZ46dW0Y8BkloqsE6hMgrSW+ZjEmMm3Pv1/
         jXeUUR3h7Vco5pajrTrQCX/JdRbOeoQQcWrHEmHVZdwsCa2rdMEMUALjcKQ/mD+JBuwi
         Ksjp8yGkddTe75eIg2zgc8cYOV93UIVGSXJexcL//XgoCHxIQ9qeVQvGGfxt/AR0l5I+
         d51A==
X-Gm-Message-State: APjAAAVhSEk8nIlXQ/s9Q/oIKn6Qjh1N4yzgRAhaUXUrGBW6k5G0qQHc
	qAA5VH7ITYHoc6zPCZdlhafAynHfGdKmZkyxWqc7Y0UbgsNNo9GJaxAqHN7P31fM4tLcQhz95Qc
	yPbaDdO3fUJT/4czNc2kbDLlcw4AmtKWZeVkSBw86jZaeAYPkNG9rNiSRztmNwkPj9Q==
X-Received: by 2002:a81:6386:: with SMTP id x128mr41835560ywb.331.1558572860710;
        Wed, 22 May 2019 17:54:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxP8teoRM9bszNWyA/6segRj139ObRs109UDnzO8QS/9KZTCvWhmZ9mhrp5tHpvePPgW9l8
X-Received: by 2002:a81:6386:: with SMTP id x128mr41835530ywb.331.1558572859522;
        Wed, 22 May 2019 17:54:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558572859; cv=none;
        d=google.com; s=arc-20160816;
        b=HhAeo8j4ZVeGjPn+TjV/nu0x6ihg+A/ND1/qOc8qBhasRac3yYlGkhZXW9E0mg76Qs
         lDzmPyTTB2eRBPMJBr22GNVATm9llUAaRv9tprbLIBoyeRsFvBECc9ktDPZ9iKXpEvXz
         IHh+5GHYbjflvlirbKQ2G33rrSFWW6ZXKKWWpk32W+zyq7h+a0Zgb5DhGtFn0XLP1KTz
         VvokoMNZdDXdpONwLhF1KLWO5niUr0u9jJ3Rk3+YnS/JXsy5tKFuecqLQIVbko/JdekN
         W8Mnrg7OQZJyiR2NTl54cvKa1WTUeIUUlV/4UqwRfRs+FanaUGcYbmfx3nRryaYNntZt
         GtYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=OwzzXwM/wBQ9KUQhbTFgOHznyorW4zimbRGODpDav1M=;
        b=maaL0niYmWg5NlEJlm7t/aa65KMNahef9U3UoMP2okomM6ItrypjM39lQC0L3TV/34
         oF3TKx8zHZpBfts24HCxnrd5PcQHJMAjucCIvlHNMbUaDILmHYa62tXhPpojq7RuxJwp
         n7kosN8ksLSeqPvqhBiVwSb6/8JubAANQXw9AKz8YLByr+ea7PD6MP9TBmJ7nbV8JLDV
         e14nZXYb7diayMsI+02MQ/cycL24jOdPUATgVR1V69mkOGoisTIhsTnsBIDZ2dkQdo5v
         NsBJSKg3NkDdRGiPUDMnAOUR0OjRnbCm9KSoLf6j6rXBuQ0HaX0fU9Mw8ZXEXXpQStiQ
         Jd1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=A4WEzCxS;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id v136si7395383ywv.192.2019.05.22.17.54.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 17:54:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=A4WEzCxS;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce5ef3a0001>; Wed, 22 May 2019 17:54:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 22 May 2019 17:54:18 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 22 May 2019 17:54:18 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 00:54:17 +0000
Subject: Re: [PATCH 5/5] mm/hmm: Fix mm stale reference use in hmm_free()
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Dan Williams
	<dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh
	<bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, Matthew
 Wilcox <willy@infradead.org>, Souptick Joarder <jrdr.linux@gmail.com>, Andrew
 Morton <akpm@linux-foundation.org>
References: <20190506233514.12795-1-rcampbell@nvidia.com>
 <20190522233628.GA16137@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <2938d2da-424d-786e-5486-1e4fa9f58425@nvidia.com>
Date: Wed, 22 May 2019 17:54:17 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190522233628.GA16137@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558572858; bh=OwzzXwM/wBQ9KUQhbTFgOHznyorW4zimbRGODpDav1M=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=A4WEzCxStGF2bVjTs0Vk2nE5uSAGGkRAFb1RswMSwFAdxNJ31kWvM7bvIMcKPIwUh
	 QNnNPM5Xh5WdfQlBTksbaaeXPpaXVJE078blrXRJPlVO+K8DEu/szWlyxqE77p4KE2
	 74uI84M/i8pIiYv2iyqJAlqC1XSZxdEc4v2umvVOykx17YwaGWFxhqp8+3+7O69hC8
	 ondEdyUx7t9ZPtZ7lPTczrP6QV5swLJKKILaTk05tlrbtx7nDHrZzEE1x5BDWqqOvp
	 6PaelAc0wjcR2nc3RT3zt1qkp1zm9k3ewv2fIwKFh1lSTm1tbRAKqj67CVwz1jSzf3
	 GXYhY0a7rlE+A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/22/19 4:36 PM, Jason Gunthorpe wrote:
> On Mon, May 06, 2019 at 04:35:14PM -0700, rcampbell@nvidia.com wrote:
>> From: Ralph Campbell <rcampbell@nvidia.com>
>>
>> The last reference to struct hmm may be released long after the mm_struct
>> is destroyed because the struct hmm_mirror memory may be part of a
>> device driver open file private data pointer. The file descriptor close
>> is usually after the mm_struct is destroyed in do_exit(). This is a good
>> reason for making struct hmm a kref_t object [1] since its lifetime spans
>> the life time of mm_struct and struct hmm_mirror.
> 
>> The fix is to not use hmm->mm in hmm_free() and to clear mm->hmm and
>> hmm->mm pointers in hmm_destroy() when the mm_struct is
>> destroyed.
> 
> I think the right way to fix this is to have the struct hmm hold a
> mmgrab() on the mm so its memory cannot go away until all of the hmm
> users release the struct hmm, hmm_ranges/etc
> 
> Then we can properly use mmget_not_zero() instead of the racy/abnormal
> 'if (hmm->xmm == NULL || hmm->dead)' pattern (see the other
> thread). Actually looking at this, all these tests look very
> questionable. If we hold the mmget() for the duration of the range
> object, as Jerome suggested, then they all get deleted.
> 
> That just leaves mmu_notifier_unregister_no_relase() as the remaining
> user of hmm->mm (everyone else is trying to do range->mm) - and it
> looks like it currently tries to call
> mmu_notifier_unregister_no_release on a NULL hmm->mm and crashes :(
> 
> Holding the mmgrab fixes this as we can safely call
> mmu_notifier_unregister_no_relase() post exit_mmap on a grab'd mm.
> 
> Also we can delete the hmm_mm_destroy() intrustion into fork.c as it
> can't be called when the mmgrab is active.
> 
> This is the basic pattern we used in ODP when working with mmu
> notifiers, I don't know why hmm would need to be different.
> 
>> index 2aa75dbed04a..4e42c282d334 100644
>> +++ b/mm/hmm.c
>> @@ -43,8 +43,10 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>>   {
>>   	struct hmm *hmm = READ_ONCE(mm->hmm);
>>   
>> -	if (hmm && kref_get_unless_zero(&hmm->kref))
>> +	if (hmm && !hmm->dead) {
>> +		kref_get(&hmm->kref);
>>   		return hmm;
>> +	}
> 
> hmm->dead and mm->hmm are not being read under lock, so this went from
> something almost thread safe to something racy :(
> 
>> @@ -53,25 +55,28 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>>    * hmm_get_or_create - register HMM against an mm (HMM internal)
>>    *
>>    * @mm: mm struct to attach to
>> - * Returns: returns an HMM object, either by referencing the existing
>> - *          (per-process) object, or by creating a new one.
>> + * Return: an HMM object reference, either by referencing the existing
>> + *         (per-process) object, or by creating a new one.
>>    *
>> - * This is not intended to be used directly by device drivers. If mm already
>> - * has an HMM struct then it get a reference on it and returns it. Otherwise
>> - * it allocates an HMM struct, initializes it, associate it with the mm and
>> - * returns it.
>> + * If the mm already has an HMM struct then return a new reference to it.
>> + * Otherwise, allocate an HMM struct, initialize it, associate it with the mm,
>> + * and return a new reference to it. If the return value is not NULL,
>> + * the caller is responsible for calling hmm_put().
>>    */
>>   static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>>   {
>> -	struct hmm *hmm = mm_get_hmm(mm);
>> -	bool cleanup = false;
>> +	struct hmm *hmm = mm->hmm;
>>   
>> -	if (hmm)
>> -		return hmm;
>> +	if (hmm) {
>> +		if (hmm->dead)
>> +			goto error;
> 
> Create shouldn't fail just because it is racing with something doing
> destroy
> 
> The flow should be something like:
> 
> spin_lock(&mm->page_table_lock); // or write side mmap_sem if you prefer
> if (mm->hmm)
>     if (kref_get_unless_zero(mm->hmm))
>          return mm->hmm;
>     mm->hmm = NULL
> 
> 
>> +		goto out;
>> +	}
>>   
>>   	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
>>   	if (!hmm)
>> -		return NULL;
>> +		goto error;
>> +
>>   	init_waitqueue_head(&hmm->wq);
>>   	INIT_LIST_HEAD(&hmm->mirrors);
>>   	init_rwsem(&hmm->mirrors_sem);
>> @@ -83,47 +88,32 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>>   	hmm->dead = false;
>>   	hmm->mm = mm;
>>   
>> -	spin_lock(&mm->page_table_lock);
>> -	if (!mm->hmm)
>> -		mm->hmm = hmm;
>> -	else
>> -		cleanup = true;
>> -	spin_unlock(&mm->page_table_lock);
> 
> BTW, Jerome this needs fixing too, it shouldn't fail the function just
> because it lost the race.
> 
> More like
> 
> spin_lock(&mm->page_table_lock);
> if (mm->hmm)
>     if (kref_get_unless_zero(mm->hmm)) {
>          kfree(hmm);
>          return mm->hmm;
>     }
> mm->hmm = hmm
> 
>> -	if (cleanup)
>> -		goto error;
>> -
>>   	/*
>> -	 * We should only get here if hold the mmap_sem in write mode ie on
>> -	 * registration of first mirror through hmm_mirror_register()
>> +	 * The mmap_sem should be held for write so no additional locking
> 
> Please let us have proper lockdep assertions for this kind of stuff.
> 
>> +	 * is needed. Note that struct_mm holds a reference to hmm.
>> +	 * It is cleared in hmm_release().
>>   	 */
>> +	mm->hmm = hmm;
> 
> Actually using the write side the mmap_sem seems sort of same if it is
> assured the write side is always held for this call..
> 
> 
> Hmm, there is a race with hmm_destroy touching mm->hmm that does
> hold the write lock.
> 
>> +
>>   	hmm->mmu_notifier.ops = &hmm_mmu_notifier_ops;
>>   	if (__mmu_notifier_register(&hmm->mmu_notifier, mm))
>>   		goto error_mm;
> 
> And the error unwind here is problematic as it should do
> kref_put. Actually after my patch to use container_of this
> mmu_notifier_register should go before the mm->hmm = hmm to avoid
> having to do the sketchy error unwind at all.
> 
>> +out:
>> +	/* Return a separate hmm reference for the caller. */
>> +	kref_get(&hmm->kref);
>>   	return hmm;
>>   
>>   error_mm:
>> -	spin_lock(&mm->page_table_lock);
>> -	if (mm->hmm == hmm)
>> -		mm->hmm = NULL;
>> -	spin_unlock(&mm->page_table_lock);
>> -error:
>> +	mm->hmm = NULL;
>>   	kfree(hmm);
>> +error:
>>   	return NULL;
>>   }
>>   
>>   static void hmm_free(struct kref *kref)
>>   {
>>   	struct hmm *hmm = container_of(kref, struct hmm, kref);
>> -	struct mm_struct *mm = hmm->mm;
>> -
>> -	mmu_notifier_unregister_no_release(&hmm->mmu_notifier, mm);
> 
> Where did the unregister go?
> 
>> -
>> -	spin_lock(&mm->page_table_lock);
>> -	if (mm->hmm == hmm)
>> -		mm->hmm = NULL;
>> -	spin_unlock(&mm->page_table_lock);
> 
> Well, we still need to NULL mm->hmm if the hmm was put before the mm
> is destroyed.
> 
>>   	kfree(hmm);
>>   }
>> @@ -135,25 +125,18 @@ static inline void hmm_put(struct hmm *hmm)
>>   
>>   void hmm_mm_destroy(struct mm_struct *mm)
>>   {
>> -	struct hmm *hmm;
>> +	struct hmm *hmm = mm->hmm;
>>   
>> -	spin_lock(&mm->page_table_lock);
>> -	hmm = mm_get_hmm(mm);
>> -	mm->hmm = NULL;
>>   	if (hmm) {
>> +		mm->hmm = NULL;
> 
> At this point The kref on mm is 0, so any other thread reading mm->hmm
> has a use-after-free bug. Not much point in doing this assignment , it
> is just confusing.
> 
>>   		hmm->mm = NULL;
>> -		hmm->dead = true;
>> -		spin_unlock(&mm->page_table_lock);
>>   		hmm_put(hmm);
>> -		return;
>>   	}
>> -
>> -	spin_unlock(&mm->page_table_lock);
>>   }
>>   
>>   static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>>   {
>> -	struct hmm *hmm = mm_get_hmm(mm);
>> +	struct hmm *hmm = mm->hmm;
> 
> container_of is much safer/better
> 
>> @@ -931,20 +909,14 @@ int hmm_range_register(struct hmm_range *range,
>>   		return -EINVAL;
>>   	if (start >= end)
>>   		return -EINVAL;
>> +	hmm = mm_get_hmm(mm);
>> +	if (!hmm)
>> +		return -EFAULT;
>>   
>>   	range->page_shift = page_shift;
>>   	range->start = start;
>>   	range->end = end;
>> -
>> -	range->hmm = mm_get_hmm(mm);
>> -	if (!range->hmm)
>> -		return -EFAULT;
>> -
>> -	/* Check if hmm_mm_destroy() was call. */
>> -	if (range->hmm->mm == NULL || range->hmm->dead) {
> 
> This comment looks bogus too, we can't race with hmm_mm_destroy as the
> caller MUST have a mmgrab or mmget on the mm already to call this API
> - ie can't be destroyed.
> 
> As discussed in the other thread this should probably be
> mmget_not_zero.
> 
> Jason

I think you missed the main points which are:

1) mm->hmm holds a reference to struct hmm so hmm isn't going away until
    __mmdrop() is called. hmm->mm is not a reference to mm,
   just a "backward" pointer.
   Trying to make struct hmm hold a *reference* to mm seems wrong to me.

2) mm->hmm is only set with mm->mmap_sem held for write.
    mm->hmm is only cleared when __mmdrop() is called.
    hmm->mm is only cleared when __mmdrop() is called so it is long 
after the call to hmm_release().

3) The mmu notifier unregister happens only as part of exit_mmap().

The hmm->dead and hmm->mm == NULL checks are more for sanity checking
since hmm_mirror_register() shouldn't be called without holding mmap_sem.
A VM_WARN or other check makes sense like you said.

Anyway, I'll wait for Jerome to weigh in as to how to proceed.

