Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92C91C10F09
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 02:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 221E920663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 02:04:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="i9027WbB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 221E920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9072C8E0003; Tue,  5 Mar 2019 21:04:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88EF48E0001; Tue,  5 Mar 2019 21:04:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 732928E0003; Tue,  5 Mar 2019 21:04:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2B58E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 21:04:38 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id e4so11634825pfh.14
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 18:04:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=rp+EqwcLxAs6h2sIfzKgeVXiunRhEMOEhWjqu8NVtN8=;
        b=ncmYC08aPZ8dp/TztuoFhhmBaNUrdslhW4OD+r6PQzfC964KKOVc0nCh8BcGvNJKOg
         xdTto0Gcqwcw0sIpS/ZbuvHzWmJwpJKNp8IO+7AQDw6OWVFd42PrdYvIoJpikw3YBjVf
         q+TWaz0Xd8sEc4Kr/QesjmcB7qv2o1CjoPbA3FpiOher6qBzWm4zQjPJTxwwrx9u9A2I
         +n0XSbrCBLODxeHLKyI5C3LwYuCL2m6NzsrTyXyDrq2lg8Swk290RszhnRsPgdDVmrZ0
         3Mxhw5XJBi5y14mPwn7HQKOlxiFY+ROHkOZXUWgHwA8XQZRBxCs2jUY8aoJul/WAh7Ec
         SUPQ==
X-Gm-Message-State: APjAAAU3OWWH05Z2pgOHNQ54dtt8iN5aSULG/XT1PFC0zSo50BwIjEaN
	kEiRuiphoSwiInuay4SyaNIjRN2/feLUumPhsDhz3WTeFFBYuYSXG5Pjfd9TRVhArnYxDxSYd45
	ZhpBlxz51NNa1fCU47YHnBMmpH44dB6Rr5A7K4FWeSYQgJe3QtKiacmEcnW/9IqStww==
X-Received: by 2002:aa7:8847:: with SMTP id k7mr4740046pfo.99.1551837877782;
        Tue, 05 Mar 2019 18:04:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqxgDP0UVjl4BhPbnQpsyC1DRJK7xNIBog6aTahU0GacwY/YYLLeuwEiC+Vme6lPi17S8nr3
X-Received: by 2002:aa7:8847:: with SMTP id k7mr4739982pfo.99.1551837876828;
        Tue, 05 Mar 2019 18:04:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551837876; cv=none;
        d=google.com; s=arc-20160816;
        b=IKWFKoQR7zFHfIBa84sXsJSVp3NinGqSlVmcNr8Il+BtVBQ2WN+xOkV0KzJ2G39vAA
         DdlUeGpXqj4kDUtsh+iOLiF7eT8dFTj5j6NjATF+5w4rKYND9zfmXhH6iFCfjUZSvAgP
         6tMBA/IZgSgAomsubKduaVHRsS8uoncjD8XR6NG6ozq4rg1l2S26Fs+XSHgRXjvyesUF
         9xee7YxGmadWIUCAbMJ6siLHxPxvz+BO3lFB4Ehy5dEByiObbRB/oPWIjEtMfQVZA+uI
         vxVyLWj9Adr/zbyThPk9ZQkRX5MDoZMXx+5HUOtCxg/g2zD/G9SluXWYNWX8xINLNAbc
         SYNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=rp+EqwcLxAs6h2sIfzKgeVXiunRhEMOEhWjqu8NVtN8=;
        b=LU9LnAQsSfnf3Ffudj1UzNncxfZJukWUV6rHfURNR8DbBmTjIXCDslyRw6NcYRIFtb
         W0xm+1Q2AyjU8/AEtxE4TsYqW6E5IGj18Pju06uBIFhgD5itV6AcxXIbgqVT1YEhJeJl
         uPWsnbFn2iIxjDCZrQH+7Zw1ojTUddbORNEFVgerkbm0I8mV+JzDHyuU9/QkcCjH3D/h
         vIB2+BoJh/HRTEQPAHQFjC6IzMCmitppmt6NrD3FtIfATL+r/IuQIJJ5Y/g4K1+5V2/N
         41i+UmmvBAEk6Uh+g5LIc0T4DhVXh3GOCIb8JxFE/qgPPYxLJRkDuRKSsA5Mkz70GzAe
         /wBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=i9027WbB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id o26si410871pfi.141.2019.03.05.18.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 18:04:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=i9027WbB;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7f2ab30000>; Tue, 05 Mar 2019 18:04:35 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 05 Mar 2019 18:04:36 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 05 Mar 2019 18:04:36 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 6 Mar
 2019 02:04:35 +0000
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Artemy Kovalyov <artemyko@mellanox.com>, Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
 <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
 <903383a6-f2c9-4a69-83c0-9be9c052d4be@mellanox.com>
 <20190306013213.GA1662@ziepe.ca>
 <74f196a1-bd27-2e94-2f9f-0cf657eb0c91@nvidia.com>
 <be6303c6-d8d2-483a-5271-b6707c21178e@nvidia.com>
 <20190306015123.GB1662@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1f922d79-0057-ed80-305c-01768dd40cad@nvidia.com>
Date: Tue, 5 Mar 2019 18:04:35 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190306015123.GB1662@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551837875; bh=rp+EqwcLxAs6h2sIfzKgeVXiunRhEMOEhWjqu8NVtN8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=i9027WbBk1QDJvGlMPz43I4bjPtR+8kQ3Qe8qTjCZhgoEfMYxXWIuFdRaEuKiC8gy
	 h3ERXxuT+FuM5Ttk2RGejBBXVtURrvVQ8Kn8i3kLDdw1C5yXfKewVvTQn5EDyYEqGm
	 B1bg6oiZh85z6ZCVoiJwrnIB5qxQfI2wRE7PCLywl5Zuuq/4VjDB13Z54PFZy79d+V
	 4AeIIeQl/KdkZvoIdwc3/RRtOESyovJReuhajO4x7ocAuZG6YkPR1oABb8oVrQJBsY
	 zXzSsRKW2u/6OBYh5cg1kk9ZIpo9Hy9EjwufJl9zCU4aMfv8y9iVe8ty2BqsEoYVjI
	 y93TEEXRXUl+A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/5/19 5:51 PM, Jason Gunthorpe wrote:
> On Tue, Mar 05, 2019 at 05:37:18PM -0800, John Hubbard wrote:
>> On 3/5/19 5:34 PM, John Hubbard wrote:
>> [snip]
>>>>> So release_pages(&local_page_list[j+1], npages - j-1) would be correct.
>>>>
>>>> Someone send a fixup patch please...
>>>>
>>>> Jason
>>>
>>> Yeah, I'm on it. Just need to double-check that this is the case. But Jason,
>>> you're confirming it already, so that helps too.
> 
> I didn't look, just assuming Artemy is right since he knows this
> code..
> 

OK. And I've confirmed it, too.

>>> Patch coming shortly.
>>>
>>
>> Jason, btw, do you prefer a patch that fixes the previous one, or a new 
>> patch that stands alone? (I'm not sure how this tree is maintained, exactly.)
> 
> It has past the point when I should apply a fixup, rdma is general has
> about an approximately 1 day period after the 'thanks applied' message
> where rebase is possible
> 
> Otherwise the tree is strictly no rebase
> 
> Jason
> 

Got it, patch is posted now.

thanks,
-- 
John Hubbard
NVIDIA

