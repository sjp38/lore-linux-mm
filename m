Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BE19C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A59052184E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:43:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="fqCfzymR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A59052184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FA7B6B0003; Thu, 28 Mar 2019 18:43:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A9636B0006; Thu, 28 Mar 2019 18:43:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 273FC6B0007; Thu, 28 Mar 2019 18:43:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1C9A6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:43:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so84950pff.1
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:43:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=DcTAs+RSEkOcHewXHOJx5fT44ep803/s6eVsj6wv86o=;
        b=gFPY9eQwoDPRTavDwzgVJwuVCw8YmzIBfhk4DVwepCAWKoAXzP57S+U0PXWmEQd4Ub
         WeRlM6TQiJzgF/OnEqn75pHXUs6q/fXrzwd+CV4KzG4gXTaq8yJOpRkNgC9Z1poFaCc9
         aTc+6/iTg7cjL7b6j47kA6lly2/tLyy7CtHyo3aGX1ude106WB2wYpeJ+smqYQMbcWIb
         ER+0T1urOF7vduqk6WnXfAg0YgbEaCkD5fnZy4YgeqiJLMZunIBlUcBS2DQsT//FFl1h
         FiQra9lhP3utBCiJtm6V7X4DA6WkmwHnNBdI6cbwTOCHFXF5nomE/MrLpfVT+PQ8X5i4
         1n/g==
X-Gm-Message-State: APjAAAUv6YM+OTaeqnhsQDtt3Q8uMWBvY7QqQnOgNcjBoYyY0nb1PLYs
	+EBCimyUnMVwW59mOErCTndXCFggIq4qNHZ2f9QY8nCW9NoMxhwynA5TS/TsfP5OY8FMC09lPwz
	HdFm3oXzzgmvKBbsFIpT3QDXo05f3whZk6KH4c2e25V0ivWZpLqL9suXWA64LuFEIVQ==
X-Received: by 2002:aa7:938b:: with SMTP id t11mr36476626pfe.67.1553813016520;
        Thu, 28 Mar 2019 15:43:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyM/HKC6WDXl6mhkvoh1Qm3Ktsevm4UtNwqyNcQX4OVKJ2Prod0pyORKtRsKj3Rx2HZBtRX
X-Received: by 2002:aa7:938b:: with SMTP id t11mr36476543pfe.67.1553813015433;
        Thu, 28 Mar 2019 15:43:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553813015; cv=none;
        d=google.com; s=arc-20160816;
        b=HOgjlqGFjuK28/BGwPFBXFBY85ON1iVXd+D9YN1+ltel9kROoEfIh+l9/CQ+OvxH7X
         AFpw9za7RKlXsU01NawByeR+109l4Bg+fB3tDnM8+3uEK+lagbLDF1SPCSaSh8O1a+Xk
         XqgWem8A8vfhFy+GZDKZKsjIOdH0Ci8IvAwCWUDAumu2klIhSA+BryoNshJomROHwdtZ
         jkB79bBnbnUBR6IkhwROtaldU/Ng3kgiLUE+/XMnjqQ3HeHHa8tqYi12+0QUj7VZYtA0
         4vMMjTua56QdWQRJhP0bLNjfgYJ7YenFPYREHKgMtcVAgv5acvtux5o35OxIjujNHAmc
         cuAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=DcTAs+RSEkOcHewXHOJx5fT44ep803/s6eVsj6wv86o=;
        b=S9sToAx59ziNpeJ1QweTS75KcAfJEMGrzZJUbv5moKoZtumnUIa2a0r9XXUq50CT8k
         f4nLpEA9J66t3k1ujnoZue5EaVu29UQjG5eVAIm60w45rz2drwBp+HfFbR2k5PbxVFOo
         QuT9dIhSU3L2mHUOHh38H45lalIxZjO4INBBQcG7o8OFjqX0smlxMHqknLZ6KC+xqsZU
         KXnPlFZm5/ihdb0+USlJf1U/LpabYF6INS0hJ6G+vFK1zMXIWsCV+K9b2deOtOXCLlY7
         gmfo4uwjJY9rpO+dXNobnjRsP8xFVOAh4AKlHZpp6AzyXivTrUPPmGZNuryuntitMGl9
         UKrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fqCfzymR;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k11si332199pga.257.2019.03.28.15.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:43:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=fqCfzymR;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d4e100000>; Thu, 28 Mar 2019 15:43:28 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 15:43:34 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 15:43:34 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 22:43:34 +0000
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
To: Jerome Glisse <jglisse@redhat.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
 <20190328220824.GE13560@redhat.com>
 <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
 <20190328224032.GH13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <0b698b36-da17-434b-b8e7-4a91ac6c9d82@nvidia.com>
Date: Thu, 28 Mar 2019 15:43:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328224032.GH13560@redhat.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553813008; bh=DcTAs+RSEkOcHewXHOJx5fT44ep803/s6eVsj6wv86o=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=fqCfzymRBwe06GbbaIg/emJtGsMWQFPZpY67qKL8qfduXrfydUvE/YvqWCp/D8I4Q
	 4QBnHWIzsc+3Ua0IcQ+4I21b0pONocX62CGFo57tKlpEJVeny6IdoXQpZKMAUHGqUG
	 SZpjiAuRP5eMCE5PCCenpxqwyrlKOPXKe4hfg2lJ/GKAbq14MQipJDUJgVnr+Sv8D+
	 54HbY9/pX4BdHjM6pIJPHQHOIuvS8RO5Px8WEab0r3xzVZfECLdxez2TA6MFgdQ9SF
	 xxbCsT5mlqM12rS+/XTGFpwK46CZdWpdM8T5yCKV0JE4SLuQS3KcrRfvZ69nFdpk+I
	 yneGprQsdjPvg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 3:40 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 03:25:39PM -0700, John Hubbard wrote:
>> On 3/28/19 3:08 PM, Jerome Glisse wrote:
>>> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
>>>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
>>>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>> [...]
>>>>
>>>>>>
>>>>>> If you insist on having this wrapper, I think it should have approxi=
mately=20
>>>>>> this form:
>>>>>>
>>>>>> void hmm_mirror_mm_down_read(...)
>>>>>> {
>>>>>> 	WARN_ON(...)
>>>>>> 	down_read(...)
>>>>>> }=20
>>>>>
>>>>> I do insist as it is useful and use by both RDMA and nouveau and the
>>>>> above would kill the intent. The intent is do not try to take the loc=
k
>>>>> if the process is dying.
>>>>
>>>> Could you provide me a link to those examples so I can take a peek? I
>>>> am still convinced that this whole thing is a race condition at best.
>>>
>>> The race is fine and ok see:
>>>
>>> https://cgit.freedesktop.org/~glisse/linux/commit/?h=3Dhmm-odp-v2&id=3D=
eebd4f3095290a16ebc03182e2d3ab5dfa7b05ec
>>>
>>> which has been posted and i think i provided a link in the cover
>>> letter to that post. The same patch exist for nouveau i need to
>>> cleanup that tree and push it.
>>
>> Thanks for that link, and I apologize for not keeping up with that
>> other review thread.
>>
>> Looking it over, hmm_mirror_mm_down_read() is only used in one place.
>> So, what you really want there is not a down_read() wrapper, but rather,
>> something like
>>
>> 	hmm_sanity_check()
>>
>> , that ib_umem_odp_map_dma_pages() calls.
>=20
> Why ? The device driver pattern is:
>     if (hmm_is_it_dying()) {
>         // handle when process die and abort the fault ie useless
>         // to call within HMM
>     }
>     down_read(mmap_sem);
>=20
> This pattern is common within nouveau and RDMA and other device driver in
> the work. Hence why i am replacing it with just one helper. Also it has t=
he
> added benefit that changes being discussed around the mmap sem will be ea=
sier
> to do as it avoid having to update each driver but instead it can be done
> just once for the HMM helpers.

Yes, and I'm saying that the pattern is broken. Because it's racy. :)

>>>>>>> +{
>>>>>>> +	struct mm_struct *mm;
>>>>>>> +
>>>>>>> +	/* Sanity check ... */
>>>>>>> +	if (!mirror || !mirror->hmm)
>>>>>>> +		return -EINVAL;
>>>>>>> +	/*
>>>>>>> +	 * Before trying to take the mmap_sem make sure the mm is still
>>>>>>> +	 * alive as device driver context might outlive the mm lifetime.
>>>>>>
>>>>>> Let's find another way, and a better place, to solve this problem.
>>>>>> Ref counting?
>>>>>
>>>>> This has nothing to do with refcount or use after free or anthing
>>>>> like that. It is just about checking wether we are about to do
>>>>> something pointless. If the process is dying then it is pointless
>>>>> to try to take the lock and it is pointless for the device driver
>>>>> to trigger handle_mm_fault().
>>>>
>>>> Well, what happens if you let such pointless code run anyway?=20
>>>> Does everything still work? If yes, then we don't need this change.
>>>> If no, then we need a race-free version of this change.
>>>
>>> Yes everything work, nothing bad can happen from a race, it will just
>>> do useless work which never hurt anyone.
>>>
>>
>> OK, so let's either drop this patch, or if merge windows won't allow tha=
t,
>> then *eventually* drop this patch. And instead, put in a hmm_sanity_chec=
k()
>> that does the same checks.
>=20
> RDMA depends on this, so does the nouveau patchset that convert to new AP=
I.
> So i do not see reason to drop this. They are user for this they are post=
ed
> and i hope i explained properly the benefit.
>=20
> It is a common pattern. Yes it only save couple lines of code but down th=
e
> road i will also help for people working on the mmap_sem patchset.
>=20

It *adds* a couple of lines that are misleading, because they look like the=
y
make things safer, but they don't actually do so.

thanks,
--=20
John Hubbard
NVIDIA

