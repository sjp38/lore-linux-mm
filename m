Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5352C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:12:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 587772054F
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 21:12:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="KQ4MO4k8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 587772054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 026916B0003; Wed, 22 May 2019 17:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F192E6B0006; Wed, 22 May 2019 17:12:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE1B46B0007; Wed, 22 May 2019 17:12:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBC446B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 17:12:37 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id x8so3315756ybp.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 14:12:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mX/CdrHkooQO7jjbW8rAIvvhdT+nRmphKetM9at3fl4=;
        b=M9QH7Vwr4D8B7xmbExMLhL8CgTXA01DfkjoiABdcmj9BjRRUoi8cew0I09GUgphDil
         KoAv3Wwgpx/SEN0DpBXBmasbSdaolkn5ENUA8NTPNold+TSQTXbyKYb3urmTqVnLFMev
         ZEsSLdOitOMo9IKZCQiZFFqGqQXJbwF8ptb+abr+7gDbCHzxnDGE/ivpc3GrgDARkYoq
         B6UArahd0c2kLwvsMZ/qF2IdjmJbQsTRST2rD7o10RQogjTIDnfH/kRS/0IfbpIbxFoe
         nOAmUAxfheu2i/SF1fnrbPh7r5VcM2HaVt/b4HebtQpsblC49C0YN3vLm64JLddQLup9
         VXwQ==
X-Gm-Message-State: APjAAAX7jkpcd5B9GmHQx+DMQdWMJ0FCXy9KN4+QxiMvF7JSRuDYCozb
	9Eo2GSs9B/q5LFzSwc5rbcsqSv2OitAyYxDPGwNKGpKYhy39KAFuTz30P7iStvqI9MAhjFveFnF
	GZTMzuveyNp3wh6RVVxLR/Geuz5E8NmergUoWF6jn5vkVcMxfE/+Oml9pyrrhpVHHbQ==
X-Received: by 2002:a81:3617:: with SMTP id d23mr19986281ywa.77.1558559557375;
        Wed, 22 May 2019 14:12:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9+2QWkgdcL6yPhVUunIb2drzphf68g0JjB1/XdAUUYTKy1eQt4hD4bFdw8ELuAyBqMBot
X-Received: by 2002:a81:3617:: with SMTP id d23mr19986242ywa.77.1558559556713;
        Wed, 22 May 2019 14:12:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558559556; cv=none;
        d=google.com; s=arc-20160816;
        b=plnyERHA3TNivNq0AYyuFLZhmjOVVtiWMfRlvHLEhM0yVzhTwfJ2dTTAr1+zLLYwY5
         /6/ay+R5LFLvFVERwFSpZ+InlcFkr9MKezPcZEHpOcnPoyWZUW2+8BlnvbM+1idBwe3Z
         w6meoGCad4vT2FZs8FPzNd03yJfmfvruzVOv9edPOJiklYLQ5kGhD5SR7nhWB023K2Wg
         2dOlfZRybzJF8S+Cv/IE5z78wHZ3tGFodtsF94Ls5JN3td6bKKeuOYWQUg3Wrj7FKdVC
         r8EO5BvS0imZNFrkWz7UwgbWvdhD53PA5ZEJXwB6L9RMqCpmnH4ANihNQWKvQ/hRd82k
         2Ivg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mX/CdrHkooQO7jjbW8rAIvvhdT+nRmphKetM9at3fl4=;
        b=MST3by/baZ47H+Er7j+HF5ZOFFrGb0uTNYDQ8rcJJF2W7/OlwIdN29F9ieWuu9ssA2
         K9q8i1PITG0QRXdV34jdc8cjLS6QO9bLSEnuCsUVFuDKcnALzcnwt7RvNyYNJkH5cKxJ
         wHEUKj+0gsRmDmlb6Py+VsKZ7hzKrn1ujjcI/kS4BYAVN65EEEqkGQlyKDyF9jQexKSP
         7nGfhsKL8x2OI13ndoEgU9h7kiHagtaK8wd18K8TTpnvjd/IjofxbsDUeoaVa2ENQ7Cl
         FtS4FomJvmUg4DCB0uE/USxg2Ws6lDfygRU9OIasip9wtsTrh8wCJzvinTN3upHpkLsG
         svwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KQ4MO4k8;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id y6si3126466ybs.357.2019.05.22.14.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 14:12:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=KQ4MO4k8;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce5bb430000>; Wed, 22 May 2019 14:12:35 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 22 May 2019 14:12:35 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 22 May 2019 14:12:35 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 22 May
 2019 21:12:31 +0000
Subject: Re: [PATCH v4 0/1] Use HMM for ODP v4
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	<linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <linux-rdma@vger.kernel.org>, "Leon
 Romanovsky" <leonro@mellanox.com>, Doug Ledford <dledford@redhat.com>,
	"Artemy Kovalyov" <artemyko@mellanox.com>, Moni Shoua <monis@mellanox.com>,
	"Mike Marciniszyn" <mike.marciniszyn@intel.com>, Kaike Wan
	<kaike.wan@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>
References: <20190411181314.19465-1-jglisse@redhat.com>
 <20190506195657.GA30261@ziepe.ca> <20190521205321.GC3331@redhat.com>
 <20190522005225.GA30819@ziepe.ca> <20190522174852.GA23038@redhat.com>
 <20190522201247.GH6054@ziepe.ca>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <05e7f491-b8a4-4214-ab75-9ecf1128aaa6@nvidia.com>
Date: Wed, 22 May 2019 14:12:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190522201247.GH6054@ziepe.ca>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558559555; bh=mX/CdrHkooQO7jjbW8rAIvvhdT+nRmphKetM9at3fl4=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=KQ4MO4k8l+72nJLn6i84C3CQ35IQKGD8fCmAUJnqiaH43emJ+Tq4QMnDM3at0c3oG
	 fKaiKcy3laigtGeONQU/lsCHwd+hKJwBy8kBAPM9CvkmalcPYHm8/SINlAY7n5SLLk
	 zw5vUeGhoN9s80rB8pwmqrzjT7VEK8mPmWOGD4k0CcAfOFOMxLZksmbNYWxU7hku78
	 VgBIGRWR7WGIPQ33NlYQNDB/zOJ9Phe2rNUIw723n+00aZn5TK99hVsVyz8gV9/ajv
	 Bw7OrdqLmaHMwWhtpVOsMF+1IQutmqv5wLHPEhWmgmdTUwyA542iZcapvY4q7VI2aD
	 ehyNrkOI11anw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/22/19 1:12 PM, Jason Gunthorpe wrote:
> On Wed, May 22, 2019 at 01:48:52PM -0400, Jerome Glisse wrote:
> 
>>   static void put_per_mm(struct ib_umem_odp *umem_odp)
>>   {
>>   	struct ib_ucontext_per_mm *per_mm = umem_odp->per_mm;
>> @@ -325,9 +283,10 @@ static void put_per_mm(struct ib_umem_odp *umem_odp)
>>   	up_write(&per_mm->umem_rwsem);
>>   
>>   	WARN_ON(!RB_EMPTY_ROOT(&per_mm->umem_tree.rb_root));
>> -	mmu_notifier_unregister_no_release(&per_mm->mn, per_mm->mm);
>> +	hmm_mirror_unregister(&per_mm->mirror);
>>   	put_pid(per_mm->tgid);
>> -	mmu_notifier_call_srcu(&per_mm->rcu, free_per_mm);
>> +
>> +	kfree(per_mm);
> 
> Notice that mmu_notifier only uses SRCU to fence in-progress ops
> callbacks, so I think hmm internally has the bug that this ODP
> approach prevents.
> 
> hmm should follow the same pattern ODP has and 'kfree_srcu' the hmm
> struct, use container_of in the mmu_notifier callbacks, and use the
> otherwise vestigal kref_get_unless_zero() to bail:

You might also want to look at my patch where
I try to fix some of these same issues (5/5).

https://marc.info/?l=linux-mm&m=155718572908765&w=2


>  From 0cb536dc0150ba964a1d655151d7b7a84d0f915a Mon Sep 17 00:00:00 2001
> From: Jason Gunthorpe <jgg@mellanox.com>
> Date: Wed, 22 May 2019 16:52:52 -0300
> Subject: [PATCH] hmm: Fix use after free with struct hmm in the mmu notifiers
> 
> mmu_notifier_unregister_no_release() is not a fence and the mmu_notifier
> system will continue to reference hmm->mn until the srcu grace period
> expires.
> 
>           CPU0                                     CPU1
>                                                 __mmu_notifier_invalidate_range_start()
>                                                   srcu_read_lock
>                                                   hlist_for_each ()
>                                                     // mn == hmm->mn
> hmm_mirror_unregister()
>    hmm_put()
>      hmm_free()
>        mmu_notifier_unregister_no_release()
>           hlist_del_init_rcu(hmm-mn->list)
> 			                           mn->ops->invalidate_range_start(mn, range);
> 					             mm_get_hmm()
>        mm->hmm = NULL;
>        kfree(hmm)
>                                                       mutex_lock(&hmm->lock);
> 
> Use SRCU to kfree the hmm memory so that the notifiers can rely on hmm
> existing. Get the now-safe hmm struct through container_of and directly
> check kref_get_unless_zero to lock it against free.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>   include/linux/hmm.h |  1 +
>   mm/hmm.c            | 25 +++++++++++++++++++------
>   2 files changed, 20 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 51ec27a8466816..8b91c90d3b88cb 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -102,6 +102,7 @@ struct hmm {
>   	struct mmu_notifier	mmu_notifier;
>   	struct rw_semaphore	mirrors_sem;
>   	wait_queue_head_t	wq;
> +	struct rcu_head		rcu;
>   	long			notifiers;
>   	bool			dead;
>   };
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 816c2356f2449f..824e7e160d8167 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -113,6 +113,11 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
>   	return NULL;
>   }
>   
> +static void hmm_fee_rcu(struct rcu_head *rcu)
> +{
> +	kfree(container_of(rcu, struct hmm, rcu));
> +}
> +
>   static void hmm_free(struct kref *kref)
>   {
>   	struct hmm *hmm = container_of(kref, struct hmm, kref);
> @@ -125,7 +130,7 @@ static void hmm_free(struct kref *kref)
>   		mm->hmm = NULL;
>   	spin_unlock(&mm->page_table_lock);
>   
> -	kfree(hmm);
> +	mmu_notifier_call_srcu(&hmm->rcu, hmm_fee_rcu);
>   }
>   
>   static inline void hmm_put(struct hmm *hmm)
> @@ -153,10 +158,14 @@ void hmm_mm_destroy(struct mm_struct *mm)
>   
>   static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   {
> -	struct hmm *hmm = mm_get_hmm(mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   	struct hmm_mirror *mirror;
>   	struct hmm_range *range;
>   
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
> +
>   	/* Report this HMM as dying. */
>   	hmm->dead = true;
>   
> @@ -194,13 +203,15 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>   static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   	struct hmm_mirror *mirror;
>   	struct hmm_update update;
>   	struct hmm_range *range;
>   	int ret = 0;
>   
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return 0;
>   
>   	update.start = nrange->start;
>   	update.end = nrange->end;
> @@ -248,9 +259,11 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
>   static void hmm_invalidate_range_end(struct mmu_notifier *mn,
>   			const struct mmu_notifier_range *nrange)
>   {
> -	struct hmm *hmm = mm_get_hmm(nrange->mm);
> +	struct hmm *hmm = container_of(mn, struct hmm, mmu_notifier);
>   
> -	VM_BUG_ON(!hmm);
> +	/* hmm is in progress to free */
> +	if (!kref_get_unless_zero(&hmm->kref))
> +		return;
>   
>   	mutex_lock(&hmm->lock);
>   	hmm->notifiers--;
> 

