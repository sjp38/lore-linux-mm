Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F60AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:33:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BED85205C9
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:33:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kXNHhFIl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BED85205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 562768E0165; Mon, 11 Feb 2019 17:33:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F8398E0163; Mon, 11 Feb 2019 17:33:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B1C68E0165; Mon, 11 Feb 2019 17:33:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16B048E0163
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:33:56 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id w17so365038ybm.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:33:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=YrcCJUXUeBjmMXB4uAD+t8FoXjzbCfi0g/YDioIq2Sw=;
        b=Q6cxP2ODsjW1jrDXV4jbaQTy5inKf6J0nnbgkhwxUrBgIoyMqSfFNPloUetRFSiXA1
         EDkpxl+8KdOcGpyMdRJpaizcXzXqor/jo6kA+K4ZjeM7qN1gpMf3fwiJVChNdRZ8fhHA
         9Ets8zbfjaO1lVYxTC1BOtdTnV1rHZ1FICkv1oZCdRvqXJrVzf9pDLYhvUexcOSrtu4V
         XHOF2d9wXnm5cMGXVGp5/IhZO70cRFitmMx0ZQdEp+TaSVMVRUAQs1sEIDFgBEVKQT+9
         ypeK2A7rzk20h9aTLEH1byHPynh597ekqL7TpxOAHm/kchzr39+S5tRKLdQ2aS0WVDYk
         fmLw==
X-Gm-Message-State: AHQUAuZceZvyZhoIUdXSPFvPXXCzx9sKJcRjmFST/mdog9QZ10B2z89v
	xE59TwgXN9Ft8MHJJ6leKqBL3q2/WFC2rrUU+SdHyPLyEDuMDLs22fmeED+iSDVipJFjrNPUAQH
	YhupII2hnrN3rQeblZmnex2+JPDLM4XZ/ARWUipvIPFqR9zjZSdam0etANJ2ONKV3Rg==
X-Received: by 2002:a25:d28b:: with SMTP id j133mr439951ybg.124.1549924435752;
        Mon, 11 Feb 2019 14:33:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhaxp84AarIfmoDgGo8cLFVyci+gM677ZZD0w4OIbIFJLAoqF/j5yidvYOcGlTX9BtaamF
X-Received: by 2002:a25:d28b:: with SMTP id j133mr439918ybg.124.1549924435082;
        Mon, 11 Feb 2019 14:33:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549924435; cv=none;
        d=google.com; s=arc-20160816;
        b=WALrMk/AbhMM0he+xzL+/mYP91gFiDXjIFgBXhV7oueVpIzcVB3ZrVl+1PcDg9RrLa
         516aquddNHi5sv60EHzTmVJ6+PENK44tjLvSwcQx51JAFRkPw2m3T2ke4bR/ey2vIepD
         ZLAJKCnBhLKydX1gzUgvyBRiz8qNRmnpTPw/6G9dq+IbPW0RS45tlUYSltz+TviHBZSr
         E/EU/BqGHkLqk58H3k4UA/wUbgr0a9Zpkyvln6jK+uptJaRNooM+zXj3XSkAJqA96xFq
         YTcwmX4+I9olIQcV8RcQi4vJfj1f8RP62QUaMidOc/+ROCkjRleL1gp6bdJRgjpK21Tr
         5ccg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=YrcCJUXUeBjmMXB4uAD+t8FoXjzbCfi0g/YDioIq2Sw=;
        b=J6sSVMXfZzX+wAsltu/sWNX7SB7+iSRVLjZIoNFkOPe9+/EkK0RDBdRtsZxwbsGccf
         scxuYVBxHUzeiVsOjStgzEdALuaeUAo/O0CIW6O9CRj/Yv9qyNckUJcQyA16XmfWeDne
         HLm6in+Qw7khV+VrYy6NZGGO+9ysNXRWta2aQn75wGOAxJ7/Azt1Ll4JQMGukQUtsi/W
         eiSOHf8tBqYTMRuVFuotlGzBaQ2AENOmLXJMUlJolD7QL/NLLiVTkZDYRWVMNbsFR5a2
         d/ahhgUZwPARAGVKm3wnxN4FUI8ZeUhx+ZLUBUkiPEIrHmjX8ba8eZEkC60MEwouaSgi
         hUrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kXNHhFIl;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v73si6372774ybv.359.2019.02.11.14.33.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:33:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kXNHhFIl;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c61f8540000>; Mon, 11 Feb 2019 14:33:56 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 11 Feb 2019 14:33:54 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 11 Feb 2019 14:33:54 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 11 Feb
 2019 22:33:53 +0000
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
CC: Ira Weiny <ira.weiny@intel.com>, Dan Williams <dan.j.williams@intel.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Christopher
 Lameter <cl@linux.com>, Doug Ledford <dledford@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, <lsf-pc@lists.linux-foundation.org>, linux-rdma
	<linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, Jerome Glisse
	<jglisse@redhat.com>, Michal Hocko <mhocko@kernel.org>
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard> <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <fb507b56-7f8f-cf2c-285c-bae3b2d72c4f@nvidia.com>
 <20190211221247.GI24692@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <018c1a05-5fd8-886a-573b-42649949bba8@nvidia.com>
Date: Mon, 11 Feb 2019 14:33:53 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211221247.GI24692@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549924436; bh=YrcCJUXUeBjmMXB4uAD+t8FoXjzbCfi0g/YDioIq2Sw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=kXNHhFIlhXR6pc/L0Z1RTsNAjsVn4a6I560QWLYgQ/t3+67h3c1paRKSx60lQxe0p
	 96BPi5SdqVdeSYR/Z1X7YmtQLd9GURSz4xtlAI2vtr5b82Vwtn+p/pkGq8RDPYigHU
	 ZuuNEPd5AU2TPsX66w/GQLDFVIcd/DMFAN5TLcnqJeSq81JKez3cfR7HeQNyIGDl2w
	 sprTQRrmmTv/AJ9hWUI7vermVLhyEFMgQtS7EjVnt0mN2KXDkHZaw2ZJc6Lb0ut3cG
	 Jxc14gDufMUn/mJsi0Gk/AZWTUFARxEQnKlobPAEnQoxMnFHz0ogmBMiEDrKK9NRgS
	 R4CnKnY1GNrfw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 2:12 PM, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 01:22:11PM -0800, John Hubbard wrote:
> 
>> The only way that breaks is if longterm pins imply an irreversible action, such
>> as blocking and waiting in a way that you can't back out of or get interrupted
>> out of. And the design doesn't seem to be going in that direction, right?
> 
> RDMA, vfio, etc will always have 'long term' pins that are
> irreversible on demand. It is part of the HW capability.
> 

Yes, I get that about the HW. But I didn't quite phrase it accurately. What I
meant was, irreversible from the kernel code's point of view; specifically,
the filesystem while in various writeback paths.

But anyway, Jan's proposal a bit earlier today [1] is finally sinking into
my head--if we actually go that way, and prevent the caller from setting up
a problematic gup pin in the first place, then that may make this point sort
of moot.


> I think the flag is badly named, it is really more of a
> GUP_LOCK_PHYSICAL_ADDRESSES flag.
> 
> ie indicate to the FS that is should not attempt to remap physical
> memory addresses backing this VMA. If the FS can't do that it must
> fail.
> 

Yes. Duration is probably less important than the fact that the page
is specially treated.

[1] https://lore.kernel.org/r/20190211102402.GF19029@quack2.suse.cz
thanks,
-- 
John Hubbard
NVIDIA

