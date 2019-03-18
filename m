Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5063EC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 20:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0019D2173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 20:12:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="kdfzspIO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0019D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84F306B0005; Mon, 18 Mar 2019 16:12:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D6AF6B0006; Mon, 18 Mar 2019 16:12:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 652F26B0007; Mon, 18 Mar 2019 16:12:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 230CA6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 16:12:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j10so19584988pff.5
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:12:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=iGAUPJJ+Q3A71Lvl21ZNq7fTQp4p5vmBmHlE40N1XP8=;
        b=iroPhbh8Ko+VVZZfKgMK9AIotQXXZu4FFeEGy3KQ2gkV+5SXP6kyjBgTLW5YkMunmN
         ymQqeVQBFSGErzLplOq8yz/FokQAmz8lFti9gGVEbN7wAL/79hp5pLhlHdcG0Xt3zJyo
         3N5YETqQOafALakxcbEWdhWou9fyksYIVuItBSBpXUDzdVfObBFTz3QbAz81tjt3gIxb
         Juqlv1JajDp6RgEu0dB1YIzgQTpe1rIIlTAr7t/U4WVKb0rPld8+F3sQi2ms/Q+vjtUQ
         j+O5GjC52/T3BbE5HjDhPnt/MdIo3lJ14lTWLU4Mxg6/J1Hc3EGw/oMJpPymahhTHb5M
         aaPg==
X-Gm-Message-State: APjAAAUoxqJJeRunqD8xxp5fBRCFEIvQEde8wJCUyT4axu3PDyOAWVA7
	c/l6S8OLSfpzwRgY4xQkp6yX7KgPVCGG2HetXceEBPf+VWnwdFhZrcnBOPpDEWbmAJRSvW+fen5
	mvfvFuBR/Rpwk3qALiFEiAU6V4ExXR0tgqtXaO6iGjB/iMhx0hxO9/3ojd/KCBXx9dg==
X-Received: by 2002:a63:68ca:: with SMTP id d193mr19225194pgc.53.1552939969744;
        Mon, 18 Mar 2019 13:12:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKt+n8HsdO6q1OnKbMzmCTySrXw6MnssjRMaN8Nwm458kpeVJLmx4U5itJRmg5bWFgVk5v
X-Received: by 2002:a63:68ca:: with SMTP id d193mr19225107pgc.53.1552939968656;
        Mon, 18 Mar 2019 13:12:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552939968; cv=none;
        d=google.com; s=arc-20160816;
        b=cIRqCoPMs0VYOA+9/J8vXhtaKJLvQ6qqgbnAZ3Pr3FaBQFOgHbFQT9EwFuYlM+iWnu
         SaZkl4kyB+tnMwR07T+TSmM/gifBs8OLoRCm1hdADDpj7ldkTMz1ZUoBOp6ZNCi2iMVV
         vi6B9fGjDFsvtqI7+AUyuGUXibBKEb/nAk+GbGyTckPuDACMeH0OeZgAxUEYGo64/hmi
         E/lQ1HvkowO8HbkhPAg/hyJBV++MnjcV0TZwSEyXUv5cbk5WSQ6TxtwvTNCz7yMkU5+O
         +XZCpHmHWBcms9TH68hTmQpedRvGe3fy6gTb7Js2xIW1WKl9rv1QOc39Sysu5Obtrtyn
         pv/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=iGAUPJJ+Q3A71Lvl21ZNq7fTQp4p5vmBmHlE40N1XP8=;
        b=FOcISRoJEfgeBi9GVOsaaNoL+M/HvOARR3nsYnKke5THYJWGfCrI8MDsr0zRqOI6sX
         p6nBtykGBpQnDn5oW/5ZM+jEWzABB1AKrUGHytL+zcn2RijWnPDi4umrINOoNNFBMjs8
         RgB2LILfllZdIsSrWov6jamFEhBAkRuHQtOJqFggwWQd3B5OqawxHvzFfbHdSIu3eWW+
         Ec9ex9w045/G2wfk4b7QHBb362rm1EnpciUzH5j46qcPnPiblEQMviCrWSIK+IYzdOhC
         NbmtEcKFNE1YuFz7U20ZJk4jlmwXPYs+m+MLKOYG7iub1+CnubYVqIzy2LcGNmK4MOLj
         958Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kdfzspIO;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f6si9744432pgc.99.2019.03.18.13.12.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 13:12:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=kdfzspIO;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c8ffbb10000>; Mon, 18 Mar 2019 13:12:33 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 18 Mar 2019 13:12:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 18 Mar 2019 13:12:47 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 18 Mar
 2019 20:12:47 +0000
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
To: Jan Kara <jack@suse.cz>, Christopher Lameter <cl@linux.com>
CC: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Dan
 Williams <dan.j.williams@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason
 Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190310224742.GK26298@dastard>
 <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
 <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
 <20190312221113.GF23020@dastard> <20190313160319.GA15134@infradead.org>
 <010001697880bfdc-4503d0dd-03cd-4c91-84a0-c18af1eab145-000000@email.amazonses.com>
 <20190314090635.GC16658@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <445e6907-2fd7-1eeb-21f6-e7fa00d00346@nvidia.com>
Date: Mon, 18 Mar 2019 13:12:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190314090635.GC16658@quack2.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552939953; bh=iGAUPJJ+Q3A71Lvl21ZNq7fTQp4p5vmBmHlE40N1XP8=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=kdfzspIOMbdNIz/V4toshBZcPvyHARFKk/GxlRerAg4U8EZ/Ck8XeretMa1qlqxB0
	 9hZQUw49H3B9nr7wc2DTPBpQAUNUHqbohF9c+u2HwqGb03mHntxjVXlbGNMhfFCnRy
	 DsYWC9Zdw6hEDsL2CE+KKjS/tRnEK5BHek4C5Fa4Jn+xCPuLMVITBYdYHrH8816lTu
	 0B7MjwmiMhbz55bziJkKiVlZv67ghCPmoRSPELgtuaTW7jB1u1gGqGlWrp1K1jcnuF
	 VSsRGR/kES8782fEmJVBtPp3K8M134jW7KuT49l0PsUITEAJAFukDIHbL8Pm890V+K
	 TRspMJldCevUg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/14/19 2:06 AM, Jan Kara wrote:
> On Wed 13-03-19 19:21:37, Christopher Lameter wrote:
>> On Wed, 13 Mar 2019, Christoph Hellwig wrote:
>>
>>> On Wed, Mar 13, 2019 at 09:11:13AM +1100, Dave Chinner wrote:
>>>> On Tue, Mar 12, 2019 at 03:39:33AM -0700, Ira Weiny wrote:
>>>>> IMHO I don't think that the copy_file_range() is going to carry us through the
>>>>> next wave of user performance requirements.  RDMA, while the first, is not the
>>>>> only technology which is looking to have direct access to files.  XDP is
>>>>> another.[1]
>>>>
>>>> Sure, all I doing here was demonstrating that people have been
>>>> trying to get local direct access to file mappings to DMA directly
>>>> into them for a long time. Direct Io games like these are now
>>>> largely unnecessary because we now have much better APIs to do
>>>> zero-copy data transfer between files (which can do hardware offload
>>>> if it is available!).
>>>
>>> And that is just the file to file case.  There are tons of other
>>> users of get_user_pages, including various drivers that do large
>>> amounts of I/O like video capture.  For them it makes tons of sense
>>> to transfer directly to/from a mmap()ed file.
>>
>> That is very similar to the RDMA case and DAX etc. We need to have a way
>> to tell a filesystem that this is going to happen and that things need to
>> be setup for this to work properly.
> 
> The way to tell filesystem what's happening is exactly what we are working
> on with these patches...
> 
>> But if that has not been done then I think its proper to fail a long term
>> pin operation on page cache pages. Meaning the regular filesystems
>> maintain control of whats happening with their pages.
> 
> And as I mentioned in my other email, we cannot just fail the pin for
> pagecache pages as that would regress existing applications.
> 
> 								Honza
> 

Christopher L,

Are you OK with this approach now? If so, I'd like to collect any additional
ACKs people are willing to provide, and ask Andrew to consider this first 
patch for 5.2, so we can get started.

thanks,
-- 
John Hubbard
NVIDIA

