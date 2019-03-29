Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1990C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 20:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BBAB218A3
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 20:07:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="eX2VKtNM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BBAB218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0603C6B0008; Fri, 29 Mar 2019 16:07:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E646B000A; Fri, 29 Mar 2019 16:07:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3E4C6B000D; Fri, 29 Mar 2019 16:07:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A90F76B0008
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 16:07:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f67so2206743pfh.9
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:07:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=GSqEMrrxwhxreIUm3fGaxmGkN2Y6WWPBPr8DyC7ajdk=;
        b=mpEM7/ghuNMeXegI9feKOtksu1/VFPEKk/J5OhNgyDtdUVbFptAE2oWyGXzRDtTDc4
         w/6zmiro4OISdonYmrZXHrQwNBYnFfhgStnw6f1hVBfHOXVJ8e0U9g0ayBmKpfIcVwbO
         R3ipy9/fypkcxNTO9M5UJlfWEQnwWkqT+PRndhiqH+FslGnm48MKm5YS7rxSMOe8r8xy
         EMKVY336KH8aQp63HzY4QqFFs/B9w1pMvCQ0juGDtupYWrs0FsvHaNB9M3gQUCFrCnzg
         2VtXJkNox3qFHWnNpYTAG2P52+duO2Mh15+1iWxNN6dldpiCQsoU0baNY3x0YZ+swtsi
         tboQ==
X-Gm-Message-State: APjAAAWgyrpsliUb18FE6ChQtssJYZpI9FyNbosATlCrOJCrC5ygT6bH
	RCKYDymgM+rv+LR5VHvW+LPG/lvX0I1h8ic5jzYvoEXh7scskV1dS3JYFRq8v1am+66soxfCEPI
	/RYwhoDzgHzIqOTL4mDX8q2RxiXFRnzmxdssGhkP9IbsRmQNzGmQTdA8/U4c5phKL5A==
X-Received: by 2002:a65:6496:: with SMTP id e22mr33255119pgv.249.1553890067306;
        Fri, 29 Mar 2019 13:07:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwTrgLfR7TCi+9CevZ5AIKmPMw2ST07Jnz35IBTKBTOqWw7q4DQFPTJb0bo760aoOHSLT2
X-Received: by 2002:a65:6496:: with SMTP id e22mr33255050pgv.249.1553890066421;
        Fri, 29 Mar 2019 13:07:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553890066; cv=none;
        d=google.com; s=arc-20160816;
        b=r9In3jzWfA0qD6pl+g0+J+hD4Qp9Ln5bPj8QWHtIJXOiWxJdzQU9XCYtAN+2FSasGi
         bPs1IqbRnjOZjspNcaZX6Xxi6ZMUep3n95eXP6MR0GYlxX6G+vz7FOas6z8aFyh3rrf9
         hRfpdQ5eMud/xJS95oeDikbsMNFN+7Fi4VS2ralkecZzHe62vT4cN1TbkyCC1lphmTDX
         HchV3d/zZBPeZ6wJxKSxE5HHIEHw50MqQg2YkLhQzvpKJHgixQtPva+vM/a6CPCZHndf
         72eOWe5t/VXFfgnv3RCIBi5fabhgAlbzd7GbEub0xpquZAWvw5jSbcKlofhuBPCG2mJ+
         JBHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=GSqEMrrxwhxreIUm3fGaxmGkN2Y6WWPBPr8DyC7ajdk=;
        b=ThG/OhwLInHWiPcs71aLxfVZx7biOw9JWEXOZ1QJY9QddYMzQq4oSmS+vtRonJn/w6
         Zd63OBIPpM23vOiOoq7Vh+Y6wEtgIPbDu9xXl7EHt1clqrfGxktQ1DGPyRNd48WDBf/K
         0Q++jtEnG+01jOGx6vwy3blFHbHouCC2QQ6UAP9qYiZPhMnd/fY6KFkSGewDd+5grxxG
         aIpgZ908AxTAgxTyF09Zi7J2tZj9RtUVFHGTTjiCnq5n+1GeYiXwjOxyrFusD9vmvIV/
         n1utUJmNB39CeKYM6u4sq+Qn+2yfbxvt+a4T9EXT1bN8oCaBXIQdB5FZI9/H44dMJ3ys
         Y39g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eX2VKtNM;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id r6si2468909pfn.165.2019.03.29.13.07.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 13:07:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=eX2VKtNM;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9e7b150000>; Fri, 29 Mar 2019 13:07:49 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 29 Mar 2019 13:07:45 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 29 Mar 2019 13:07:45 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 20:07:45 +0000
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
To: Jerome Glisse <jglisse@redhat.com>, Ira Weiny <ira.weiny@intel.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
 <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
 <20190328165708.GH31324@iweiny-DESK2.sc.intel.com>
 <20190329010059.GB16680@redhat.com>
 <55dd8607-c91b-12ab-e6d7-adfe6d9cb5e2@nvidia.com>
 <20190329015003.GE16680@redhat.com>
 <20190328182100.GJ31324@iweiny-DESK2.sc.intel.com>
 <20190329022519.GJ16680@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <144f034d-9688-5aad-7b68-34e1d4b08228@nvidia.com>
Date: Fri, 29 Mar 2019 13:07:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190329022519.GJ16680@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553890069; bh=GSqEMrrxwhxreIUm3fGaxmGkN2Y6WWPBPr8DyC7ajdk=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=eX2VKtNMLTYQHApWKfo7Py4nw6DR6FufYnyTH7xN4/q7QHLQD4wa6pyTXQ8yQIOxu
	 37jg/uGN19UB4Wnf8zGU0jz9+URnrPDJSCGL9ii8yJY9Vd67CKrmaaZwfpkeZ8tfmA
	 +7IoQ7vzHyMuQFJ9ClsU8RL0znbOjUymNa8Iza2TeqQhpdRkpajBzGilV2Q4RYimLW
	 FcPW5d8bhLF395MQsSi15im16UUj2Lw4cKorTKdV6+ahGKIMcQvEupqXqogfjsvFaY
	 MLRyJC2y/5BmmZcUvpqJDq+6eLiALwHMWLJ7YoBVuarVFIoavfG2Ln8j4ur9eM4CdS
	 j+rDjaJoVGyJQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 7:25 PM, Jerome Glisse wrote:
[...]
>> The input value is not the problem.  The problem is in the naming.
>>
>> obj = get_obj( various parameters );
>> put_obj(obj);
>>
>>
>> The problem is that the function is named hmm_register() either "gets" a
>> reference to _or_ creates and gets a reference to the hmm object.
>>
>> What John is probably ready to submit is something like.
>>
>> struct hmm *get_create_hmm(struct mm *mm);
>> void put_hmm(struct hmm *hmm);
>>
>>
>> So when you are reading the code you see...
>>
>> foo(...) {
>> 	struct hmm *hmm = get_create_hmm(mm);
>>
>> 	if (!hmm)
>> 		error...
>>
>> 	do stuff...
>>
>> 	put_hmm(hmm);
>> }
>>
>> Here I can see a very clear get/put pair.  The name also shows that the hmm is
>> created if need be as well as getting a reference.
>>
> 
> You only need to create HMM when you either register a mirror or
> register a range. So they two pattern:
> 
>     average_foo() {
>         struct hmm *hmm = mm_get_hmm(mm);
>         ...
>         hmm_put(hmm);
>     }
> 
>     register_foo() {
>         struct hmm *hmm = hmm_register(mm);
>         ...
>         return 0;
>     error:
>         ...
>         hmm_put(hmm);
>     }
> 

1. Looking at this fresh this morning, Ira's idea of just a single rename
actually clarifies things a lot more than I expected. I think the following
tiny patch would suffice here (I've updated documentation to match, and added
a missing "@Return:" line too):

iff --git a/mm/hmm.c b/mm/hmm.c
index fd143251b157..37b1c5803f1e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -50,14 +50,17 @@ static inline struct hmm *mm_get_hmm(struct mm_struct *mm)
 }
 
 /*
- * hmm_register - register HMM against an mm (HMM internal)
+ * hmm_get_create - returns an HMM object, either by referencing the existing
+ * (per-process) object, or by creating a new one.
  *
- * @mm: mm struct to attach to
+ * @mm: the mm_struct to attach to
+ * @Return: a pointer to the HMM object, or NULL upon failure. This pointer must
+ * be released, when done, via hmm_put().
  *
- * This is not intended to be used directly by device drivers. It allocates an
- * HMM struct if mm does not have one, and initializes it.
+ * This is an internal HMM function, and is not intended to be used directly by
+ * device drivers.
  */
-static struct hmm *hmm_register(struct mm_struct *mm)
+static struct hmm *hmm_get_create(struct mm_struct *mm)
 {
        struct hmm *hmm = mm_get_hmm(mm);
        bool cleanup = false;
@@ -288,7 +291,7 @@ int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
        if (!mm || !mirror || !mirror->ops)
                return -EINVAL;
 
-       mirror->hmm = hmm_register(mm);
+       mirror->hmm = hmm_get_create(mm);
        if (!mirror->hmm)
                return -ENOMEM;
 
@@ -915,7 +918,7 @@ int hmm_range_register(struct hmm_range *range,
        range->start = start;
        range->end = end;
 
-       range->hmm = hmm_register(mm);
+       range->hmm = hmm_get_create(mm);
        if (!range->hmm)
                return -EFAULT;




2. A not directly related point: did you see my minor comment on patch 0001? I think it might have been missed in all the threads yesterday.



thanks,
-- 
John Hubbard
NVIDIA

