Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B24AFC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6710120820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:04:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="MK+2nS/l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6710120820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD5466B026B; Mon, 10 Jun 2019 18:04:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D859C6B026C; Mon, 10 Jun 2019 18:04:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C27BF6B026D; Mon, 10 Jun 2019 18:04:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id A38806B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:04:12 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id d6so10986978ybj.16
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:04:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=m0vRLgBt6dZ1z6MC9oHbfkHDtIvOUNsxY1buK+WfrXI=;
        b=gtEOH2VyA00q59WWU4fqUzuodUbQojKMIAEYqO2EbomPQfV5DZT3x/qRmgSA6Xxa2L
         5typFwN/16WsQDrRejQ7J32tec0Lhl0+CKhKP7AdSuL5kcrUzpjfb8S+MKuLffkJnTsq
         MucgvBYB4HDssC9p4X/CZhYt+BecLJ99+mTIeRdJeSrYYwFpyGkVnd2ghYk9+iywZJzB
         D3wedNtVd0AAC8kY0RsIbLnHpZ5yKRCpdV2FM5C0K5/YCJNc5so9DhYIlnr4RuYpu+VP
         hRY1YowObXM1PizO/ENT2G650lVKrLi6RjV906GGqN1ODvc7DNE1W9jVbtSQdrmunR7u
         jGQA==
X-Gm-Message-State: APjAAAVmYWn7BVyHPcmmMTpteymFL9zF0JoXlfOH+aKNYXleLbIWb9xl
	mF55dqGCF8SRbGZZspLjyoovIcogv83Pu9RvYS9eewViy/suo7wTrHo0T0p2h9/RIlzhkWTJDar
	ah88jZAon1+Nr7I6mINc90FxcpjRaKhMTvCor5AGh4jJ5TCzOeVqDdmvgHxWMuO2EdA==
X-Received: by 2002:a81:7805:: with SMTP id t5mr29553008ywc.312.1560204252378;
        Mon, 10 Jun 2019 15:04:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNyDAQ+/9iQu+8uOAqS9r8DBEMqYNF05+m/kHJWBfuxn4H4ZEtmTDKH1WGoPMALrfqVimh
X-Received: by 2002:a81:7805:: with SMTP id t5mr29552971ywc.312.1560204251726;
        Mon, 10 Jun 2019 15:04:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204251; cv=none;
        d=google.com; s=arc-20160816;
        b=gOTNsY7XEquy92JHZ+BPAQCQ2uZZZk8CQQacQFssZ3D/+3EdvziZiNI1knRbCEXQgV
         ZN4CRsS7DRlF/3IEVBsXEhJnK2GSrY73NKrU0bVX21XJaE41/mkSQ6GW0gQ0+HpUAJq8
         ahbsxUHBbPfcQ2s3ICKG0BflWKpNYG16r2+kVlQJ3S7/0TxO3FxopVrs7eYW+J1lRIy0
         SpIhmLeger9g3chiGY5HOOrauO56Wrv8/AjvOtNL9Qojt930zve7358PHA+9uSDFyatV
         3weYou/GVpYhYaM4yrzoRfrVYqmaG+KQRwe/J8rS000fufNVtYo76/qqZZq+IjiF7NHU
         Wy+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=m0vRLgBt6dZ1z6MC9oHbfkHDtIvOUNsxY1buK+WfrXI=;
        b=P9yC/ZOPN9xlIQoFRfZr0K+x6sY+leGWjLL74fneJQmkqFUGErLcByWYeHc7SPRx0T
         LsoFUYld7F9SIwgyg6/DvqtVLG8wxkFc3wtAFAAUNnyx9lqh1A0vkmeUl7At7uGZtrGu
         eP5PEaLGszWcx9csxLKeOahHwF2h+aRl94gTsOxw2V9Q4rYcQA7mg6fr5xeDvL0ug+Fb
         Dh0GUjqQ5hX1itO6ZJhDGvLNsebPGXj3qj9pQRXuVN63l8jyHNZunv+BVXTzelbgxBLd
         zkAP2+6zmeb5MHmxLMPepSAl5YVtsqaL2NmsLQQLJHE6ySnfq1XgoJEYhqRg40rikYHE
         Ii/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="MK+2nS/l";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id r187si3872346ywd.363.2019.06.10.15.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 15:04:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="MK+2nS/l";
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cfed3da0008>; Mon, 10 Jun 2019 15:04:11 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 10 Jun 2019 15:04:10 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 10 Jun 2019 15:04:10 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 10 Jun
 2019 22:03:42 +0000
Subject: Re: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic
 from hmm_release
To: Jason Gunthorpe <jgg@mellanox.com>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-12-jgg@ziepe.ca>
 <61ea869d-43d2-d1e5-dc00-cf5e3e139169@nvidia.com>
 <20190610160252.GH18446@mellanox.com>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <fc1487f0-f11d-8cfa-b843-f2463f3856cb@nvidia.com>
Date: Mon, 10 Jun 2019 15:03:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190610160252.GH18446@mellanox.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560204251; bh=m0vRLgBt6dZ1z6MC9oHbfkHDtIvOUNsxY1buK+WfrXI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=MK+2nS/lbaNrPz4iFJRfwJz5s4DfaMEYqsiXsGoXHqCxfcGZ/c6Y39e+9nDa6+UtB
	 jJaZ82XgncVUF58p4TxaZa2GVqE9wiPvMqe++vyh9odW/s9YHt3Dzt5HffMciwdyHK
	 cZ07IuuWfngqG3FKSghgPh1Q5YRRphYqYJrlaOqamBbUyKJGe+iYBsia5cX3iOYmlH
	 rVeyOcEQTYjPdpyYTzp+7S7HmcJDJVkE2XognFHTfxchFahTDLbSgtZsttIcyzGN2n
	 wiZ/ygt4ODCDB5+mRry4PM3VUSDeqcPhvhLhLjKCbUOnxrpb+Oszoj8fGW2ZBwqFgD
	 zEGxzmqRGVrLA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/10/19 9:02 AM, Jason Gunthorpe wrote:
> On Fri, Jun 07, 2019 at 02:37:07PM -0700, Ralph Campbell wrote:
>>
>> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
>>> From: Jason Gunthorpe <jgg@mellanox.com>
>>>
>>> hmm_release() is called exactly once per hmm. ops->release() cannot
>>> accidentally trigger any action that would recurse back onto
>>> hmm->mirrors_sem.
>>>
>>> This fixes a use after-free race of the form:
>>>
>>>          CPU0                                   CPU1
>>>                                              hmm_release()
>>>                                                up_write(&hmm->mirrors_sem);
>>>    hmm_mirror_unregister(mirror)
>>>     down_write(&hmm->mirrors_sem);
>>>     up_write(&hmm->mirrors_sem);
>>>     kfree(mirror)
>>>                                                mirror->ops->release(mirror)
>>>
>>> The only user we have today for ops->release is an empty function, so this
>>> is unambiguously safe.
>>>
>>> As a consequence of plugging this race drivers are not allowed to
>>> register/unregister mirrors from within a release op.
>>>
>>> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>>
>> I agree with the analysis above but I'm not sure that release() will
>> always be an empty function. It might be more efficient to write back
>> all data migrated to a device "in one pass" instead of relying
>> on unmap_vmas() calling hmm_start_range_invalidate() per VMA.
> 
> I think we have to focus on the *current* kernel - and we have two
> users of release, nouveau_svm.c is empty and amdgpu_mn.c does
> schedule_work() - so I believe we should go ahead with this simple
> solution to the actual race today that both of those will suffer from.
> 
> If we find a need for a more complex version then it can be debated
> and justified with proper context...
> 
> Ok?
> 
> Jason

OK.
I guess we have enough on the plate already :-)

