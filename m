Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00796C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:18:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 992932183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:18:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TvmM8cZ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 992932183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CD8E6B0003; Tue, 19 Mar 2019 21:18:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3539A6B0006; Tue, 19 Mar 2019 21:18:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F74A6B0007; Tue, 19 Mar 2019 21:18:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CF4E26B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:18:37 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g125so818965pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:18:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lUyW74g7qbSUcJU3wmjKXemQqGL0UbX2ngNwCUmFEDw=;
        b=WhbC+7yuSxMHpTFXHBcL0d3+8KL87lVfJceYmGPYXMqnkCMhuQaPtezVbaCpkXHmqB
         f82gB+3gPyBAR9grp4LqWM8pWuOtpN2HdPFX/Sq2D7RYEDNIlphYwuGadi+3gG5lFXaN
         60d4uVOz6ZZ6xKRChNp2lH9xQ5kws+TmDbRdjpye8hrOjwpEox7ceUC6/C0f1ODID3Ar
         mZgjOIsZYaX0nLUK1ZbReHJcotUIYp1yXkQ2wdO4wEvDOFgVdw7D8TfNyLabaRXh+1Oz
         gHSuIYxDlH6Mttz/4xzlJ3vaYZXApgubeWEzrwh9DCDv3+s7nWSqg18v0rdyIL0O6PID
         RxJQ==
X-Gm-Message-State: APjAAAUy8f++7NEl1myBPra2x9uaidG+UW9Fc4hvE1ak3to1jObYn78x
	Cs7l960kXxpPAd/FB+EgTl3UbahgMcaH04P/viMFhsvcTL8ZGQ8BZxPbzXW1vDPbkmr7rjRsK7o
	x1KZl2K5+IYpg31Dd7nYgSwfYE/sdIkCrTp7pw6eFJ8gyG/yYkZhNTcVzdHatipttBg==
X-Received: by 2002:aa7:8589:: with SMTP id w9mr5031158pfn.97.1553044717503;
        Tue, 19 Mar 2019 18:18:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD0m8Bj8TWaomzfEJmAtqUa2HcQ2fIUeKMGA64Uf8pdBh/5uyzBpa6+WoDHL5dYlVp0NrM
X-Received: by 2002:aa7:8589:: with SMTP id w9mr5031106pfn.97.1553044716697;
        Tue, 19 Mar 2019 18:18:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553044716; cv=none;
        d=google.com; s=arc-20160816;
        b=Ho9Ftfw9tlwF0fPiu5AV3vTm6h4ntdGeVqVi0jtGq3VMjaMHQb5KU+V/WyTveoDULJ
         q6NT+eVbJDcvOTYCVzk13ZalpOL+67Xu6kLBBBCKnpfyDTkbVtESAlOZLs1A8Kja55co
         tZIQRpZLj54FSGDFCwdiN0ikOxeSlWlcQpZoxTfl3KuOb4WyPXNtjPnXtPw8CfLScB0J
         dqfjbEopzXnjIN9IQfF/3X1QDysdbitmkc5Ow4FXQaQw1RK7NEvyHvMnqSOQoSWvYokQ
         dMWs5SkJeYd5S8/OpqfWRcXTJKwLfY7Yjtm8UQemABpKSyXn+ChG42mN26RJUVeFwLnL
         gQ7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lUyW74g7qbSUcJU3wmjKXemQqGL0UbX2ngNwCUmFEDw=;
        b=A4ZwId9tX3n6SpC7q6jazFD219G0FsyiyanVEsr9XnZkfhQJim+TyfLxgdBYPeoDjr
         GoR/XakD/PWChR3Li+74h4H3AqJuxdtgaXqRK7Xu05ORlY8mn6iWevU6o4M1ANAqu0Sq
         /si1INiVRoUSSTVHrQtk2WkDGM8xXXESaX3Nnb2hcCYDmIKKHVX7b8rLp2DIXaDx6ptb
         VNup6VAqkZQRgnyJn2obV7f9L4LcNEd7LKSbEDdivg510SB3j3WnwyjTPvcX5y5i8u+0
         /r2xWNg6orLnXTloPCKGabvu23rTyqBEjidorLR+OxEydU+uqwN1a+d5iXRnw+Hl+/81
         LZXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TvmM8cZ1;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id m7si400126pfb.272.2019.03.19.18.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 18:18:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TvmM8cZ1;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9194ee0000>; Tue, 19 Mar 2019 18:18:38 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 19 Mar 2019 18:18:36 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 19 Mar 2019 18:18:36 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 20 Mar
 2019 01:18:35 +0000
Subject: Re: [PATCH v4 0/1] mm: introduce put_user_page*(), placeholder
 versions
To: Christopher Lameter <cl@linux.com>
CC: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko
	<mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Ralph Campbell <rcampbell@nvidia.com>, Tom
 Talpey <tom@talpey.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <01000169972802f7-2d72ffed-b3a6-4829-8d50-cd92cda6d267-000000@email.amazonses.com>
 <dc2499a6-4475-bea3-605a-7778ffcf76fc@nvidia.com>
 <0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@email.amazonses.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <cd97ec48-1776-20d8-d517-35dca93f7da4@nvidia.com>
Date: Tue, 19 Mar 2019 18:18:35 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <0100016998a587a1-c6df93d4-223b-4e66-9d8c-2bb38fae28ac-000000@email.amazonses.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553044718; bh=lUyW74g7qbSUcJU3wmjKXemQqGL0UbX2ngNwCUmFEDw=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TvmM8cZ1absETn4/Ryv+cdfBfglm0ueLTDRHMr5jxLlr1/12Pdkv7L5hgchcFQHuo
	 hj1IAsDtmSDbTHPWRkdBIsT/CorqahbDPPolGR0vb42oRjhEKGw9nBUKU4uSKNU4NM
	 c+BeLdc0BMTF/zxGF1ClIX/XBqfcUOqhew/omFI/2V09SAlysy/n7xxl92mie0cSio
	 +eRHVI1wAhW4dzKyrEaFKidH+eBc04oCBh+ROlvh6gAEbH/GZ56FQUBsOnjUmyp54D
	 6wVjIAXXT6dd2aKGOuCmq+BB3qOZeN0BGu841WHazAyzgOmEjqPNQEuVk3mTguO+PY
	 7IDudyXVBHV/A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/19 6:09 PM, Christopher Lameter wrote:
> On Tue, 19 Mar 2019, John Hubbard wrote:
> 
>>>
>>> My concerns do not affect this patchset which just marks the get/put for
>>> the pagecache. The problem was that the description was making claims that
>>> were a bit misleading and seemed to prescribe a solution.
>>>
>>> So lets get this merged. Whatever the solution will be, we will need this
>>> markup.
>>>
>>
>> Sounds good. Do you care to promote that thought into a formal ACK for me? :)
> 
> Reviewed-by: Christoph Lameter <cl@linux.com>
> 

Awesome! I've added that tag and it will show up in the next posting.


thanks,
-- 
John Hubbard
NVIDIA

