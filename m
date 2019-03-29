Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 655AAC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 116FC2183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:30:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="XsyhN1AS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 116FC2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D8606B0005; Thu, 28 Mar 2019 21:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886E46B0008; Thu, 28 Mar 2019 21:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7775E6B000C; Thu, 28 Mar 2019 21:30:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 414946B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:30:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id k185so498989pga.5
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:30:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=6CXtjATayMacxoWaowYhZ6ypW2hRAvedqZ7XljR3NP0=;
        b=NKQKYQSFI2/jRf2qikeVdc1hx0PQyNVgHAJkSUpnQa4dGZpxtGPRlKZUqZkxSzTrMa
         t0hRrM3FWrmGnzLwpkEvg+mq+yVIvoZRhDU1eoIb7Kmr3qb8RuoWNtVsy9rUifJgPDl9
         iTNbuBiLChW0PYO4MOkn/GcvXdWR5rdJM/kP9ZH/Fwzs8JTN/a/lnYJq6KCMnTlB5MEK
         9hjva6eLgjEBP9Qm4PtlU4P3WV5P3nzHDLJySwgqk6Rm6zyA20Y5HJj4kmXX7BLoxNXS
         aehHtYVS9UETPA23Tgugsw5aaG1cl3aHtZY75NZ0pwKbltXYMOKRedZI4Y6N2kQU2SeC
         0ldg==
X-Gm-Message-State: APjAAAVS+ZHS0rd3ummHeBntKmZgSVBY1ixGGqKXsjya6/65lymT/T08
	qH1Gbcw7m5ps54dPVETUbsH1plsCebn5hEhsWJWWuKjCm1yNNpGw6SBDv0uZR+ooXJ3z/JtPLK0
	rhUeZG2tLILTGjVk+KfzW3Hp4zYr5UxL9fMUfbJ3dnZGc2yFvEsr2ZVEKJZLvWf6cXw==
X-Received: by 2002:a62:1a06:: with SMTP id a6mr43699711pfa.18.1553823028913;
        Thu, 28 Mar 2019 18:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtOvyu5zhjkclySB5MkylTANckBaXlDX8ASRpPT2DPncCxS9alRdrfPB9qGkVd+flmhoAW
X-Received: by 2002:a62:1a06:: with SMTP id a6mr43699650pfa.18.1553823028126;
        Thu, 28 Mar 2019 18:30:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553823028; cv=none;
        d=google.com; s=arc-20160816;
        b=vjMIWcgoueID0ZxDDp2Ui3pq0aNZFJIycpkhpo5DX8zyr1rk4iLswOyWZxovnt/8Fw
         +FxJcjsGEzkE5F5OgtyvVIis96PrJ0cVsgBxpzE/31ogFo2ftyIQALCyWMFyp1CjQV18
         Il9zF0DeyIE5+xcxl+p6VHgH4siZNfRLqL2jlzFG6OpQIwPDRxQkqGRR3qMNmN48M2OH
         PUmBE+XyNnFDLJl9y3AmMwxiLN/GMBZioV7c0J1enkscaMTwBPhYaddB5eoXlM6SwNsS
         hbSMO6W26ljHbtRK/0r79BD7FxjNsJKbGmVvzq509r1W1kYlJX3aUeQydPAgQWjLq6RT
         jUww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=6CXtjATayMacxoWaowYhZ6ypW2hRAvedqZ7XljR3NP0=;
        b=aLzpAVrSN+oNU1D1ej0ysan9PiiFljS9Q0CuC4s1n0zU1zGC+xPXqPEA+0OtVER0Od
         BvQNDVYudP0Oq9PuUpkTfyrJdZX9Mr+pVImdxFgryGkE+kLgSw1WspwttqZpLmeuKJ/2
         uuTpJgTf5Vmt/Yth3jDjtyMmPdwkUpj3gSqfJFvOa+jj7VfrWETADNtRvm462Jr3Y/D4
         ZzBLzw1Q0SVX3qQoWMg0GvJR40NzPvbLeNMPTXYIYl+educO3JTF0E9he87zUNDRL4WB
         hccduIlloywz2MOxA9DFFqUfOQWU/B3jNKCl+azow5ibmk3jl/BBfRJYUjJgCni5lP4z
         p/Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XsyhN1AS;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id i96si634032plb.322.2019.03.28.18.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 18:30:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=XsyhN1AS;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d75370000>; Thu, 28 Mar 2019 18:30:31 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 18:30:27 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 18:30:27 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 01:30:27 +0000
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
To: Jerome Glisse <jglisse@redhat.com>, Ira Weiny <ira.weiny@intel.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
 <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
 <20190329011727.GC16680@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <f053e75e-25b5-d95a-bb3c-73411ba49e3e@nvidia.com>
Date: Thu, 28 Mar 2019 18:30:26 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190329011727.GC16680@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553823031; bh=6CXtjATayMacxoWaowYhZ6ypW2hRAvedqZ7XljR3NP0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=XsyhN1ASj7Mh0dDwxw0mXugftAbLLQTdnDmNNouB6FlcjokJuiLocsVpdmB9T5dRX
	 gFx9TMvi/rO2wQxXKYSR8WOjn2ecwn5VPScbRdlKs2x5NsBv7OfY0TahE7GONGQbfy
	 TTdcfBqRqMi+lJFwenppTHbUAaOtBheAuOKSPSRC1lXbiIldfu8TVUFrKHRif+Fc0K
	 Xh74rfxCYL7J5SAWbmORiJ+84PE0+BkROLxMfI/pGxBriWk9wZyVnUhOSZAIz5xA6I
	 SL9NXQReFHiluHxyoqW5SlqBlYT+nkX6PHfMKQGmElYqgvnS4eyVM1Q+mmv4TyhU6J
	 WrI1cKMY+F4dg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 6:17 PM, Jerome Glisse wrote:
> On Thu, Mar 28, 2019 at 09:42:31AM -0700, Ira Weiny wrote:
>> On Thu, Mar 28, 2019 at 04:28:47PM -0700, John Hubbard wrote:
>>> On 3/28/19 4:21 PM, Jerome Glisse wrote:
>>>> On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
>>>>> On 3/28/19 3:31 PM, Jerome Glisse wrote:
>>>>>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
>>>>>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
>>>>>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
>>>>>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
>>>>>>>>>> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>>> [...]
>> Indeed I did not realize there is an hmm "pfn" until I saw this function=
:
>>
>> /*
>>  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
>>  * @range: range use to encode HMM pfn value
>>  * @pfn: pfn value for which to create the HMM pfn
>>  * Returns: valid HMM pfn for the pfn
>>  */
>> static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
>>                                         unsigned long pfn)
>>
>> So should this patch contain some sort of helper like this... maybe?
>>
>> I'm assuming the "hmm_pfn" being returned above is the device pfn being
>> discussed here?
>>
>> I'm also thinking calling it pfn is confusing.  I'm not advocating a new=
 type
>> but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it w=
ould
>> have shortened the discussion here.
>>
>=20
> That helper is also use today by nouveau so changing that name is not tha=
t
> easy it does require the multi-release dance. So i am not sure how much
> value there is in a name change.
>=20

Once the dust settles, I would expect that a name change for this could go
via Andrew's tree, right? It seems incredible to claim that we've built som=
ething
that effectively does not allow any minor changes!

I do think it's worth some *minor* trouble to improve the name, assuming th=
at we
can do it in a simple patch, rather than some huge maintainer-level effort.

This field name not a large thing, but the cumulative effect of having a nu=
mber of
naming glitches within HMM is significant. The size and complexity of HMM h=
as
always made it hard to attract code reviewers, so let's improve what we can=
, to
counteract that.

thanks,
--=20
John Hubbard
NVIDIA

