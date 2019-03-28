Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7FA1C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:43:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7740020811
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 20:43:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="T/vcYOjj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7740020811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11BB16B027C; Thu, 28 Mar 2019 16:43:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CD186B027E; Thu, 28 Mar 2019 16:43:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24E16B027F; Thu, 28 Mar 2019 16:43:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BB3926B027C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:43:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so83931pll.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:43:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=BWTZDuw9Jf4+5EuJDB2gXJbAkQHyJFX7dIq0NX94hfY=;
        b=ePquINhyl0FjSsoObliAy7pAkM6P6d0/5dSSGpND8IGo256UmuVtxAJ/VoYu6bmNC1
         lUZyMma0+NKr436g4wWKkTNLOjv0oE9Il5pdqbbzpn7i5nkzl0l+j7PAkmjB05u5lOc9
         gBt67UP0/8+qn4EhhbNzR3d+lIJLJ+KjC/lI49qqAakqYFC93FNKgLN3urXuBBUxXy2/
         0zks+ILRElIMH1P9zfOpowYHzgmGUKnA3bzhH94RADSXPKIviov4hHzNK3ss4U05Tnls
         ZB0O3tUNN/M/VUlb7qYT8peNIIrnZ+JCugI3s4HMOhAp/WSK+/14PRyuGVzKYEl6SwuV
         moFw==
X-Gm-Message-State: APjAAAXDPAKD2OqaftM7xeswbPK6H2gFtOPnBrD6ttJXHyICj9zT/8TO
	Toc7Q3IhPeB2dU9lN3s4baRZ07s7pO0Yim9WfvAMo3g5LSQfs7kSkh6Oi0A7cVNw/Gn18UOlJcG
	bQ1s8pYeuy/0nZ0+tZWJRex+Qn/235ZRPytd5RpX9LlkKB43CHLY/T0Pl/ewp4ALCMg==
X-Received: by 2002:a17:902:bf07:: with SMTP id bi7mr22430119plb.87.1553805795426;
        Thu, 28 Mar 2019 13:43:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn+KrFGL8PX8/epAl6hc4g9U8zpAwckOomT6nosr1BHi9qTQLZlTePO+hnTDQ5vX8fdFia
X-Received: by 2002:a17:902:bf07:: with SMTP id bi7mr22430062plb.87.1553805794572;
        Thu, 28 Mar 2019 13:43:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553805794; cv=none;
        d=google.com; s=arc-20160816;
        b=jr2bO21ntQJZEFTLryU0u5u1DIy1zz/l9pHgEigPOwxtODUXSjKrKXxgD1gZrjxb6m
         TcdlnDfUWBoKxBRNzYyTqExM7uOeTT92BS9fvPY7slUxg9JuUkHnnJD/0g11xzzSk62j
         rKcyV2VZI8McgRD2fC4SgrG0mfsK4jB5feVr/1LRaL9JJHP2HXCFw0qtvIeMhKB0TIad
         y4VI8uIC67+npohN2AaxAWUO6qoPvdDy2TBNP9HupzvFd+kj9DqEY7Y1KBvK5XLekcOg
         NwgUR1X5khi63PJQna+hfD0qrimMpQj1eOZNDeyVLSUgOhnDJUjDHW2Rtf5V5PJ8sOqm
         AMug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=BWTZDuw9Jf4+5EuJDB2gXJbAkQHyJFX7dIq0NX94hfY=;
        b=ZmJ/FORbeTuodV294TzkhZfBDEFTY8KMwlwmCNn7u6yv7z4niz1DFHUYK1dkS2Ljcp
         BEW/udl2XLvKDsPFRaVE/s2UWuW/fiyCEM+PoeohucTyRZB3yXfEmDrpizYI+EEIefoF
         ADw5VroznGe5tf5sDxjOb5uWgmmt42oAJQDsKbm/7sBSvpibsa3x8jrKv4dN+XPbpgIZ
         njKL8aiLelAlhA9zL6Tj7Don6LStQqcmZM8du7apCPpCmv8cZIhvK9/PQnmXoHgWZYyd
         MMcAM7aYQrYt9sAl0z+Qw/2KauPUxzxI8mPI/VfmL7ojTu6lWqhlqeCMkYyi4UtTXVUU
         TSyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="T/vcYOjj";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id m2si106093pll.44.2019.03.28.13.43.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 13:43:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="T/vcYOjj";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d31db0000>; Thu, 28 Mar 2019 13:43:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 13:43:13 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 28 Mar 2019 13:43:13 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 20:43:13 +0000
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
To: Jerome Glisse <jglisse@redhat.com>, Ira Weiny <ira.weiny@intel.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
Date: Thu, 28 Mar 2019 13:43:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328191122.GA5740@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553805787; bh=BWTZDuw9Jf4+5EuJDB2gXJbAkQHyJFX7dIq0NX94hfY=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=T/vcYOjjkqOeh+Fz56ku6rzMa1BCA3/mqrpXbOWH6QkV+b9Hqfr7h16DzJL+azPDg
	 J3OaHYyKzqZHXwRfbMo9R2hSAn/ZAeB848Qy//zRHMQXXg2ut7CKZWcpFZZaaF/xte
	 xGnbgwiGbCruOLTpz2cpP4iQD7MxFFlwlSEKB0ZOpHQirFl1LlP7UCPrx23PJ5bZoX
	 szbDTkVIbjcUReAiZBPgQnxBu0jUpAsIailolyBlmAG9qVe0OxoTX2wNiTy0I85yuU
	 vvC0MNnxePtyy+vOq5l9TVRIUEE7K5wYH1B5L6bhhccRpB6wSKlQLZWkNAx2giKgRJ
	 ohhus6ZW7lFfQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 12:11 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
>> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>>
>>> Every time i read the code to check that the HMM structure does not
>>> vanish before it should thanks to the many lock protecting its removal
>>> i get a headache. Switch to reference counting instead it is much
>>> easier to follow and harder to break. This also remove some code that
>>> is no longer needed with refcounting.
>>>
>>> Changes since v1:
>>>     - removed bunch of useless check (if API is use with bogus argument
>>>       better to fail loudly so user fix their code)
>>>     - s/hmm_get/mm_get_hmm/
>>>
>>> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
>>> Cc: John Hubbard <jhubbard@nvidia.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>> ---
>>>  include/linux/hmm.h |   2 +
>>>  mm/hmm.c            | 170 ++++++++++++++++++++++++++++----------------
>>>  2 files changed, 112 insertions(+), 60 deletions(-)
>>>
>>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
>>> index ad50b7b4f141..716fc61fa6d4 100644
>>> --- a/include/linux/hmm.h
>>> +++ b/include/linux/hmm.h
>>> @@ -131,6 +131,7 @@ enum hmm_pfn_value_e {
>>>  /*
>>>   * struct hmm_range - track invalidation lock on virtual address range
>>>   *
>>> + * @hmm: the core HMM structure this range is active against
>>>   * @vma: the vm area struct for the range
>>>   * @list: all range lock are on a list
>>>   * @start: range virtual start address (inclusive)
>>> @@ -142,6 +143,7 @@ enum hmm_pfn_value_e {
>>>   * @valid: pfns array did not change since it has been fill by an HMM =
function
>>>   */
>>>  struct hmm_range {
>>> +	struct hmm		*hmm;
>>>  	struct vm_area_struct	*vma;
>>>  	struct list_head	list;
>>>  	unsigned long		start;
>>> diff --git a/mm/hmm.c b/mm/hmm.c
>>> index fe1cd87e49ac..306e57f7cded 100644
>>> --- a/mm/hmm.c
>>> +++ b/mm/hmm.c
>>> @@ -50,6 +50,7 @@ static const struct mmu_notifier_ops hmm_mmu_notifier=
_ops;
>>>   */
>>>  struct hmm {
>>>  	struct mm_struct	*mm;
>>> +	struct kref		kref;
>>>  	spinlock_t		lock;
>>>  	struct list_head	ranges;
>>>  	struct list_head	mirrors;
>>> @@ -57,6 +58,16 @@ struct hmm {
>>>  	struct rw_semaphore	mirrors_sem;
>>>  };
>>> =20
>>> +static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
>>> +{
>>> +	struct hmm *hmm =3D READ_ONCE(mm->hmm);
>>> +
>>> +	if (hmm && kref_get_unless_zero(&hmm->kref))
>>> +		return hmm;
>>> +
>>> +	return NULL;
>>> +}
>>> +
>>>  /*
>>>   * hmm_register - register HMM against an mm (HMM internal)
>>>   *
>>> @@ -67,14 +78,9 @@ struct hmm {
>>>   */
>>>  static struct hmm *hmm_register(struct mm_struct *mm)
>>>  {
>>> -	struct hmm *hmm =3D READ_ONCE(mm->hmm);
>>> +	struct hmm *hmm =3D mm_get_hmm(mm);
>>
>> FWIW: having hmm_register =3D=3D "hmm get" is a bit confusing...
>=20
> The thing is that you want only one hmm struct per process and thus
> if there is already one and it is not being destroy then you want to
> reuse it.
>=20
> Also this is all internal to HMM code and so it should not confuse
> anyone.
>=20

Well, it has repeatedly come up, and I'd claim that it is quite=20
counter-intuitive. So if there is an easy way to make this internal=20
HMM code clearer or better named, I would really love that to happen.

And we shouldn't ever dismiss feedback based on "this is just internal
xxx subsystem code, no need for it to be as clear as other parts of the
kernel", right?

thanks,
--=20
John Hubbard
NVIDIA

