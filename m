Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BBC5C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:25:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C85F21850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:25:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="UZI18uN8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C85F21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D5456B0008; Thu, 28 Mar 2019 18:25:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9830D6B000C; Thu, 28 Mar 2019 18:25:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 870A16B000D; Thu, 28 Mar 2019 18:25:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 476966B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:25:42 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h15so24684pfj.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:25:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=tmWuerb4oqQAkXRnvtt8BJOgEyPuSCQS0SzrfMmcP4A=;
        b=SyOQS9QZbQYvUMHJ/GqAwnBP422GS16K5FSYX6F1KcdCJN1ADhmX2mjnsazvxwy1Jp
         WCNGETfBp6feq3u1+HRRBcfdfd9JPSN4BI1MJQGwpXa2M5XKYQPQARJqAwdH9RAK1+oS
         Sjfp3UIXhcqzYMOKUcqMbpPMI5UKF2pEDPnoUH2BZanrUOMDIuKOi42kLrXX6VMDCAk5
         jdZDYCot7LROIB30fauh910GkP2NscRhHZStACTUTUBIrSvu4W5lAy+yrMpia4PgQb+m
         L0270Pow1KW4J4hNytNYxZrdbx21DDqKJo8xtrvjvX3hTkonh2Rh5GWYtTe6qUFyhdCb
         qriw==
X-Gm-Message-State: APjAAAXGVBWfJL6ZDIrxvDC0XjXS76X4BHEs2ipSm99bnpBqii8dfcd5
	Q5RWrp96Y2O5442qXH8M+VnwEKqjilxVpbSxezUrT/biCLwaPeK/0BCwElf2TQOvxLg7D8mPLR4
	g2qDP7HForUNu6qlHrihGgvjXzgZrJZqwBnKJ0uAf0iJrzwQtqujEz3YCplwxUKmgGQ==
X-Received: by 2002:aa7:8390:: with SMTP id u16mr42801403pfm.63.1553811941866;
        Thu, 28 Mar 2019 15:25:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpBXtlzYnBq4K+MFvNCJ0ezWRWc9kVCr3lQ2udSKRDbnBw8MtFxHMbFsYZ+PjNPNzgBiXY
X-Received: by 2002:aa7:8390:: with SMTP id u16mr42801351pfm.63.1553811941082;
        Thu, 28 Mar 2019 15:25:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553811941; cv=none;
        d=google.com; s=arc-20160816;
        b=mQGQu+TeLO0efrFwRg+LUngBIaQoJJgI5TIbq4iHxxzFOpOW5tGlU+Ymg/XjUOYduP
         T26sW54TPA3ZabndFIyhGCE3VbkM+A6/Hg2vMhMheEQd1y4zm8Yik6/hSTjQxXFVhLgD
         lLoQ//QEz9ycvytr3Y8+4G6O3/4FcwTPb8Mp8E9elbuih8shzq5i1cT2sRvUpPWB37Ah
         25dhAKWuEhyIVnS5otuDLpGE7+FaJY/zMkx6kjgLgzw15wKi5s6koDfGWz++8kcgM9hY
         YAK982QD/OLwkxkVNjJMP8Rd71YVjqbgGPJQ2Y6VIh2l2hricN5oh/C//0xWLXkZBxfN
         HEzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=tmWuerb4oqQAkXRnvtt8BJOgEyPuSCQS0SzrfMmcP4A=;
        b=0E4jpCqTq+m0BarKJolFr2kEUoWKjc2nuejZFDED+CKeU09xYJlw+s6HWfuiPuTKn8
         pOWdkRhlwkduM7sIZsVjiio2CzoFo4UwhvC5PYzhZAUBrgh6zHPyHccCzaVS9XEj7TGX
         Dfyzsuu9/OXWf12CDv4D+ZHV+TSFArEpFQKxS513C75qd9g1HLeAynW2Gbs232+pIozX
         ctOHTV/st2T7quz4mIvzgc5AqnNVJLYY/YwFUvM0uhV0GKME1PoxNlYdpjFiM7XDUAeZ
         6I7DJZGqUZcfDx+cqa6KcpsApQe8272EMZwjY8K4jbx0sFmdcU3N72oU7/0tAAjcz4zK
         48Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UZI18uN8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z72si278133pgd.401.2019.03.28.15.25.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:25:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=UZI18uN8;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d49e20002>; Thu, 28 Mar 2019 15:25:38 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 15:25:40 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 28 Mar 2019 15:25:40 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 28 Mar
 2019 22:25:40 +0000
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
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <068db0a8-fade-8ed1-3b9d-c29c27797301@nvidia.com>
Date: Thu, 28 Mar 2019 15:25:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328220824.GE13560@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553811938; bh=tmWuerb4oqQAkXRnvtt8BJOgEyPuSCQS0SzrfMmcP4A=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=UZI18uN8FzlrqInNtTFT5AGFZiqb1Pc73eHhprR5NNhrgtl6h4qkQN80QPNG1lG0n
	 PVnwjztlHOxwP/AVoOZD+l6nd5oK5Jui8up9gYG0u5eXOSS7mhDTeDjBH2gu8ELBOc
	 jLr28l+wi6mUlYgSwGfSfaDUq2qnW6OZ8NY+ahefZcCkZJJYFa9ddmv1Yi7KkApOMq
	 1aUvQmcqW9tyMa980vhvthyc+j/XzYJgFcjmr4LT/au2qYq1Suqs58WtYBll2gU1tn
	 1vynV9j+mB1KLLVp3lDdQ1Qn+LNzNiUQzqInrEruSu6A3vOawyWTOwtJdkFC4Tm7Ps
	 BmYLOA4nLehgw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 3:08 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
>> On 3/28/19 2:30 PM, Jerome Glisse wrote:
>>> On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
[...]
>>
>>>>
>>>> If you insist on having this wrapper, I think it should have approxima=
tely=20
>>>> this form:
>>>>
>>>> void hmm_mirror_mm_down_read(...)
>>>> {
>>>> 	WARN_ON(...)
>>>> 	down_read(...)
>>>> }=20
>>>
>>> I do insist as it is useful and use by both RDMA and nouveau and the
>>> above would kill the intent. The intent is do not try to take the lock
>>> if the process is dying.
>>
>> Could you provide me a link to those examples so I can take a peek? I
>> am still convinced that this whole thing is a race condition at best.
>=20
> The race is fine and ok see:
>=20
> https://cgit.freedesktop.org/~glisse/linux/commit/?h=3Dhmm-odp-v2&id=3Dee=
bd4f3095290a16ebc03182e2d3ab5dfa7b05ec
>=20
> which has been posted and i think i provided a link in the cover
> letter to that post. The same patch exist for nouveau i need to
> cleanup that tree and push it.

Thanks for that link, and I apologize for not keeping up with that
other review thread.

Looking it over, hmm_mirror_mm_down_read() is only used in one place.
So, what you really want there is not a down_read() wrapper, but rather,
something like

	hmm_sanity_check()

, that ib_umem_odp_map_dma_pages() calls.


>=20
>>>
>>>
>>>>
>>>>> +{
>>>>> +	struct mm_struct *mm;
>>>>> +
>>>>> +	/* Sanity check ... */
>>>>> +	if (!mirror || !mirror->hmm)
>>>>> +		return -EINVAL;
>>>>> +	/*
>>>>> +	 * Before trying to take the mmap_sem make sure the mm is still
>>>>> +	 * alive as device driver context might outlive the mm lifetime.
>>>>
>>>> Let's find another way, and a better place, to solve this problem.
>>>> Ref counting?
>>>
>>> This has nothing to do with refcount or use after free or anthing
>>> like that. It is just about checking wether we are about to do
>>> something pointless. If the process is dying then it is pointless
>>> to try to take the lock and it is pointless for the device driver
>>> to trigger handle_mm_fault().
>>
>> Well, what happens if you let such pointless code run anyway?=20
>> Does everything still work? If yes, then we don't need this change.
>> If no, then we need a race-free version of this change.
>=20
> Yes everything work, nothing bad can happen from a race, it will just
> do useless work which never hurt anyone.
>=20

OK, so let's either drop this patch, or if merge windows won't allow that,
then *eventually* drop this patch. And instead, put in a hmm_sanity_check()
that does the same checks.


thanks,
--=20
John Hubbard
NVIDIA

