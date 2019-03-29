Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2808C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:05:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FF322173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:05:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FRvCg0fM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FF322173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C9376B000C; Thu, 28 Mar 2019 22:05:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27C266B000D; Thu, 28 Mar 2019 22:05:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 140DD6B000E; Thu, 28 Mar 2019 22:05:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7A096B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:05:23 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d10so528326pgv.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:05:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=+1O9YpiNfEVCCc+AeXkWqW7U0Khy1QDft89NTnXa5GY=;
        b=BhW72A+SdKtGXjPxJvniZ8QDUCAg0cX2bMO016hV+beOoDGR7gb9HSwLXwfBQBXIHZ
         rAswRqlOdJ9q52UE5aR35wPCaBjIwOiQVglK4ReDU9Y5dFvMhfrUPcIWTszYFNZ5Pi1F
         KDsbaVZj4P5SBfCXFtegaCz8ls92Nr7fYj0qVpVekYUJAA+IAnziiaDnU7VLFBEpJ0to
         G1XTtNzoZ7Q+Ed29H9UFE5n56bZ7/pylY49KdpuQYiAHjoRmjw6YpekahgPCkce48sHf
         9FUFJT9NcJnOMnX+cqmokQ/oD0bdnRYxjSDdypcZFousf/ZggcaAeDSPUvxPAdNMRamX
         9NrA==
X-Gm-Message-State: APjAAAVv19r8gFn/gdu3ScfmXAfmYoUrYCkGxN18dM+UiDepgtxSypCT
	lb/bLhSXD8MY3+SLK/4PaimYXhVUt7R8CUWoOO0szDBHke1hsyaTc/n5WtONthq7nyGPe2ahDZc
	2S6z6boldk4+v7kkBnC8Yvarfz9/r6mlCO8Em+Sss9AbYW+ydWhH5qHSV58V6P0FUzw==
X-Received: by 2002:aa7:814e:: with SMTP id d14mr20891877pfn.101.1553825123258;
        Thu, 28 Mar 2019 19:05:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNxe0D2w8vL0b1jl0r6so96zFO8KiL9blImgkslRfwp0jZQq2b7go6B0KFEekBZQwbWP2J
X-Received: by 2002:aa7:814e:: with SMTP id d14mr20891827pfn.101.1553825122505;
        Thu, 28 Mar 2019 19:05:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553825122; cv=none;
        d=google.com; s=arc-20160816;
        b=KBFEHDucId81kH3zXKiWewiCk9uxYfNT5t8/Ezer3DzFPqUTO3C/VkPh3IITwdYSGh
         Juohtt47VS3Rf62+7SmJyFqiUneLXiRcT2Tp+wsSHCq17+qSZcpIZaHclLTQmcEFXgSN
         zNFjzxHrmNG7ISOILCKtAcQ0PhuW7dE/hkFwcQozPQ4Si55gNkI67O8xn399RwQGBEjP
         VcwDOiSqTJhCTJ/dgX0YrEdDFd3KvZNZ6JDEabqR9kZJY0wKwe4b4K/tLCwnZVgAhwel
         C519nek0j4q3/PqwpJx+N9rvtXsC6Z3knjtD8pgIAMWc8lJnb3EQItr1Y5Rgbbw5YMfr
         +GQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=+1O9YpiNfEVCCc+AeXkWqW7U0Khy1QDft89NTnXa5GY=;
        b=EmhPExVqYBeG5w1SYyRRy7hA/xk5mIEK2tHlt0gP7/GwmaCBZr0yjt6BXAUYCdgUxv
         fvx5k5Mz9go22ngZUUPBHGw6G05KvTRZqrqfYc51+/HoXbRWQar9uS/Eit9mqL1kgdre
         zwQB/4iK9mIx/eT2ataimfJIc+rN5/2FML/gn+p2vMOMs272FLIvDYR0fxb5DMsFb+b7
         DUy39N9xahb/LaaMt4dAzHBxKpkoBtgyXALD4NmRwBUrjrkdimLISy7nbHPeF/DdbAZn
         SYAOi8PrfwZWZh0NAQ7uPNYxjRL1de+xG3PWwOchtw8JOF7dLWO8X5FbH1MktwMadtEl
         Dg3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FRvCg0fM;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id b4si695368pls.231.2019.03.28.19.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:05:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FRvCg0fM;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9d7d650000>; Thu, 28 Mar 2019 19:05:25 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 28 Mar 2019 19:05:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 28 Mar 2019 19:05:22 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 29 Mar
 2019 02:05:21 +0000
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
To: Jerome Glisse <jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>
CC: Ira Weiny <ira.weiny@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
References: <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
 <20190328164231.GF31324@iweiny-DESK2.sc.intel.com>
 <20190329011727.GC16680@redhat.com>
 <f053e75e-25b5-d95a-bb3c-73411ba49e3e@nvidia.com>
 <20190329014259.GD16680@redhat.com> <20190329015919.GF16680@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f7710f64-c17e-feef-f453-e01340461e7e@nvidia.com>
Date: Thu, 28 Mar 2019 19:05:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190329015919.GF16680@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553825125; bh=+1O9YpiNfEVCCc+AeXkWqW7U0Khy1QDft89NTnXa5GY=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FRvCg0fME4TeQCUKe5tlbRFfjI9Gn+fL4I/dhgs3fcXV6xp3Bc1c8DDtPW/Opm+nb
	 ae6YdMCZGFdkBREzXTd6995PTV+YFxEMWfQ5JbJkcFTibqmpasyWda4MuxekUso0Dw
	 GV4Gw0twubnHa5WN4YG413vAcrTP7YSnkTqJRS6q2UrKUq7IEhq21G0OLwgeW/73uI
	 ZnDXrV1pgRtf8m83kzsqcTuBgSsvwGgCM507T4p7cW53J71HhOQOoRpXMDZ3fkBYbE
	 yDSEpTSfDqkJodqYtcnYAC0vFdVebPl88NFleKIe26mGoF9ZRhYq3W0u8SUeiNQbyb
	 +8E48ZXB/twoA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/28/19 6:59 PM, Jerome Glisse wrote:
>>>>>> [...]
>>>>> Indeed I did not realize there is an hmm "pfn" until I saw this function:
>>>>>
>>>>> /*
>>>>>  * hmm_pfn_from_pfn() - create a valid HMM pfn value from pfn
>>>>>  * @range: range use to encode HMM pfn value
>>>>>  * @pfn: pfn value for which to create the HMM pfn
>>>>>  * Returns: valid HMM pfn for the pfn
>>>>>  */
>>>>> static inline uint64_t hmm_pfn_from_pfn(const struct hmm_range *range,
>>>>>                                         unsigned long pfn)
>>>>>
>>>>> So should this patch contain some sort of helper like this... maybe?
>>>>>
>>>>> I'm assuming the "hmm_pfn" being returned above is the device pfn being
>>>>> discussed here?
>>>>>
>>>>> I'm also thinking calling it pfn is confusing.  I'm not advocating a new type
>>>>> but calling the "device pfn's" "hmm_pfn" or "device_pfn" seems like it would
>>>>> have shortened the discussion here.
>>>>>
>>>>
>>>> That helper is also use today by nouveau so changing that name is not that
>>>> easy it does require the multi-release dance. So i am not sure how much
>>>> value there is in a name change.
>>>>
>>>
>>> Once the dust settles, I would expect that a name change for this could go
>>> via Andrew's tree, right? It seems incredible to claim that we've built something
>>> that effectively does not allow any minor changes!
>>>
>>> I do think it's worth some *minor* trouble to improve the name, assuming that we
>>> can do it in a simple patch, rather than some huge maintainer-level effort.
>>
>> Change to nouveau have to go through nouveau tree so changing name means:

Yes, I understand the guideline, but is that always how it must be done? Ben (+cc)?

>>  -  release N add function with new name, maybe make the old function just
>>     a wrapper to the new function
>>  -  release N+1 update user to use the new name
>>  -  release N+2 remove the old name
>>
>> So it is do-able but it is painful so i rather do that one latter that now
>> as i am sure people will then complain again about some little thing and it
>> will post pone this whole patchset on that new bit. To avoid post-poning
>> RDMA and bunch of other patchset that build on top of that i rather get
>> this patchset in and then do more changes in the next cycle.
>>
>> This is just a capacity thing.
> 
> Also for clarity changes to API i am doing in this patchset is to make
> the ODP convertion easier and thus they bring a real hard value. Renaming
> those function is esthetic, i am not saying it is useless, i am saying it
> does not have the same value as those other changes and i would rather not
> miss another merge window just for esthetic changes.
> 

Agreed, that this minor point should not hold up this patch.

thanks,
-- 
John Hubbard
NVIDIA

