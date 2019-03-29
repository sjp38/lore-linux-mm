Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C46BFC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:39:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7062F21871
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:39:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Q0KbVjt4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7062F21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 220456B0006; Thu, 28 Mar 2019 20:39:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CFB26B0007; Thu, 28 Mar 2019 20:39:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E7446B0008; Thu, 28 Mar 2019 20:39:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA25E6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:39:28 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q18so439585pll.16
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:39:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=tD7OqDvEuxyFdGL//3cLnWvjKrhcIjz2aOlgPkqRx0M=;
        b=K2yP/Frl+kuNhA/MYtZEqAZbM8Uv3LEdndFhWAhu0QcBS3OoX+PNAulMFHuzS14Y3N
         vkYx1PLv/h3cVx+osvmm2iEkL3fnqmTeTVqRqq7gX+Oka99yi6pxfZs4zy6lT5ERxCWv
         UqGuDFe10iUkl6kctYg4SHf2wJrv1azg2CJuErr2Yef1rLC3bvVuxFwE6m2Mjfqf33eT
         y2ICvwnhcrzsOieOYLkAD2mGnIKPbY/Ig9zjMg6Q2gQmDdZ4K3SS+O0lIrAzJ4M5VIvL
         g6a0S1gXCVH+af6fS/QnXzdW29DzLM3dIYP9cJtlMpwi01AmGJJzENkZauH8Y8bE7wtG
         Nk0Q==
X-Gm-Message-State: APjAAAVjC53JXNyH7OjUbYwFMtiNatWR3M8njH5eTpljkWQVhnl7auho
	a5+7vQy8VSAsl2/mJYjh6CvTScHJxKwDkl1sm0HKOWWhYuamgB6h6bd4057/QjLTTBMQMB6pfRb
	oUCuqQpc/6ylLGolcwxSCXrrpUyg4YcBOSBH2A8iHJrQvHyTkDxCkEzL2Z5mgykG6lw==
X-Received: by 2002:a63:66c4:: with SMTP id a187mr40046010pgc.369.1553819968420;
        Thu, 28 Mar 2019 17:39:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCpdB5qYWKO1RjRNtQlelxleG4f7P2DAVZnETRqzIjznRoqx0LkfVPTiOiLoBzCKtFWExV
X-Received: by 2002:a63:66c4:: with SMTP id a187mr40045973pgc.369.1553819967588;
        Thu, 28 Mar 2019 17:39:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553819967; cv=none;
        d=google.com; s=arc-20160816;
        b=bG2b6kKPTO/iFy9xqKCi1Wf9QrCqPBRdMyeokjcj00AO57HdBQBQ5rut62yBrYxbsj
         nr7QWQ8SOzLlxuLoZEGWTnENfdenNYnVbSK/E3M7J4hVOwnoR78ji9bM+obudFe9t9pM
         crvuCWkRAUJv3CyHVZPsvO1b/Lmk7YVuxr5wSuqE9FKiCNCF6YdJj225bUl8j9R98CJS
         l77RMK2qqXYMxtV7cpL98RqsHAHmkf6nc9N/50/K3RQ14WkwRmveoY6hMe8wOhHxkZXv
         jlS3v21EFieZW85DxEd7jGX2M77s3qf7NDhfDmC3n1wa9H4zHXiKdNHuBIjG+uOe1hX+
         y07Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=tD7OqDvEuxyFdGL//3cLnWvjKrhcIjz2aOlgPkqRx0M=;
        b=AMdjddQCxTiSxRs2jbpSiaYBi+5Kb8MPS6FVuFdiQD7U+tt+TqgZ8aHaMT4yaI3s1i
         3NYlTLsqWlDk+yqNU/SzzO/IkhxemsYCdAXxWrbtpdD9PMi2xsgAXXqw2jOkrIdyHOUm
         XL4ZHCveTtUx4URESugVNrMVFYvMwaK85IMaUiRujVY912xDJdOUHdf6+u0z2J72e0oZ
         vYrRQwysHgZ+dUzje9dU8jBT2FLrvJLEa814QMTkNphaKVTJAHyND0NdiFF3M8hhT4JG
         AbIbcGgIg7tG4DTXSyKAqyP7zjyMI0pdj0d/Wd1+tJihWLHWslf2hPunMomjlSxkNRtZ
         6v7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Q0KbVjt4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f65si474254pff.195.2019.03.28.17.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 17:39:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Q0KbVjt4;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d69380000>; Thu, 28 Mar 2019 17:39:20 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 17:39:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 17:39:27 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 00:39:26 +0000
Subject: Re: [PATCH v2 02/11] mm/hmm: use reference counting for HMM struct v2
To: Jerome Glisse <jglisse@redhat.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-3-jglisse@redhat.com>
 <20190328110719.GA31324@iweiny-DESK2.sc.intel.com>
 <20190328191122.GA5740@redhat.com>
 <c8fd897f-b9d3-a77b-9898-78e20221ba44@nvidia.com>
 <20190328212145.GA13560@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <fcb7be01-38c1-ed1f-70a0-d03dc9260473@nvidia.com>
Date: Thu, 28 Mar 2019 17:39:26 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190328212145.GA13560@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553819960; bh=tD7OqDvEuxyFdGL//3cLnWvjKrhcIjz2aOlgPkqRx0M=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Q0KbVjt4rsznaiVDmvDr6VuTjjWZ2rlv20UdubVR77Kk269lggejhWVS3cKh7MYkY
	 w9593VJNWmESvoEmlkOW846WaJIbzc6nUiJMLCzFkZb7GGGhQ7SGaDH2SsaebT7TNu
	 /LRNYJXErEJG+9i26NOGwgXAKU9h54GkWxEIdwAtiG3dMRVYjwLtrfjVy/hCCHKS6m
	 MWm6e+PEQx5rt+xGQzNBueRM6zrDM1MnYEp8fHDA4uoYvMTPww2Lgdk7TykKEp/Q36
	 385PMGmrePqwnlUTkvmAJjZF1+3tUhXtfanKcV5TzHTYLAvslJjSuaAhkk4O7yjm/H
	 GHjFIj7XgIAoA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 2:21 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 01:43:13PM -0700, John Hubbard wrote:
>> On 3/28/19 12:11 PM, Jerome Glisse wrote:
>>> On Thu, Mar 28, 2019 at 04:07:20AM -0700, Ira Weiny wrote:
>>>> On Mon, Mar 25, 2019 at 10:40:02AM -0400, Jerome Glisse wrote:
>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
[...]
>>>>> @@ -67,14 +78,9 @@ struct hmm {
>>>>>   */
>>>>>  static struct hmm *hmm_register(struct mm_struct *mm)
>>>>>  {
>>>>> -	struct hmm *hmm =3D READ_ONCE(mm->hmm);
>>>>> +	struct hmm *hmm =3D mm_get_hmm(mm);
>>>>
>>>> FWIW: having hmm_register =3D=3D "hmm get" is a bit confusing...
>>>
>>> The thing is that you want only one hmm struct per process and thus
>>> if there is already one and it is not being destroy then you want to
>>> reuse it.
>>>
>>> Also this is all internal to HMM code and so it should not confuse
>>> anyone.
>>>
>>
>> Well, it has repeatedly come up, and I'd claim that it is quite=20
>> counter-intuitive. So if there is an easy way to make this internal=20
>> HMM code clearer or better named, I would really love that to happen.
>>
>> And we shouldn't ever dismiss feedback based on "this is just internal
>> xxx subsystem code, no need for it to be as clear as other parts of the
>> kernel", right?
>=20
> Yes but i have not seen any better alternative that present code. If
> there is please submit patch.
>=20

Ira, do you have any patch you're working on, or a more detailed suggestion=
 there?
If not, then I might (later, as it's not urgent) propose a small cleanup pa=
tch=20
I had in mind for the hmm_register code. But I don't want to duplicate effo=
rt=20
if you're already thinking about it.


thanks,
--=20
John Hubbard
NVIDIA


