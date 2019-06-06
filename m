Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5097C28D1A
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 07:44:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B920207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 07:44:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="h3LHlMdQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B920207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C05916B0269; Thu,  6 Jun 2019 03:44:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8F5B6B026C; Thu,  6 Jun 2019 03:44:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A08846B026D; Thu,  6 Jun 2019 03:44:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC7A6B0269
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 03:44:06 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id j72so1247439ywa.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 00:44:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=mMOlfiNeriS8dHk456D4i2uPqqdGUdRNA/UjahArgCQ=;
        b=c2XM05GzAO031uohLMjSnJpoZx+BAT6D6gBT6yTt2OLuVlXQNyJfw7GEGqt14C4/Zd
         SmA5tWgKjqASoVLu/0UBYSY+bu98hTDlV6NYI2w7/v6Kpr7iPb+QHDcABAXdDwe+j4VD
         LgkJpqEufC3Wb4fV8Wgy/J7NbcVui3GCirBw4tdlj6VNyJZd87hLvDwjEkeWrxb7zE17
         O/jilaefjNoamPF7x+vVWq5TJvJ4QuXxhtJ3iYwhHIvEoUg8KjYPv3Zs3Wdi2aQ1JhQJ
         J2i3v6DtCj7Ll+ZqnzJmlRpei948+twP/7q6zk6IE1jCeCvS/bSQad0Y6GabTLf4VDNM
         bz8Q==
X-Gm-Message-State: APjAAAWUqexMay8UPp3OHnV6eM07Nbh8EQoFVoo2Ya9fpXv6Pw9PFXQr
	qm3txnHciUNL9GOICuQLYJyYaWQk56mByt+x/weHHZ3cVBPp8b3qoBM5GSn2nohqQ20iuVYXgg6
	NFab/M82FvIsIRi6i+3yjPFkz4JDdZLb/N140lgEz+GivXgV6p5uMDCsBP6mG17nzgw==
X-Received: by 2002:a81:7d86:: with SMTP id y128mr23507364ywc.443.1559807046191;
        Thu, 06 Jun 2019 00:44:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygqYnOzPfRDMOYjvGpvw3gjEjQFUbP8eFMIEV4S8bIrHnO7P2Xn8/ZniREhb1xaN1+kvog
X-Received: by 2002:a81:7d86:: with SMTP id y128mr23507340ywc.443.1559807045123;
        Thu, 06 Jun 2019 00:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559807045; cv=none;
        d=google.com; s=arc-20160816;
        b=AV7NtG77nDN/qHuqpYuZrtiyK6yvJmQnvq9hyNdvADeO8QPxeDRpx8ZJndM/bXWsvT
         FucJ4u5PMiY35MXM0pttwk4Qh4GYRHBytvWJuWQUpCCQCmoqMeWagk8v4uLrovkC+3kS
         xNy/0ZFNt+sWPTfcZ6MlukcBmJ3iiTx84abJGGqYS1lz5vSa9ElwJu5jzlKO3yeL3NL3
         aP0n0NCYLDuHTP0f6/1E36N/yRXGbwvUGs1LvUfkcJpJKxhxGL4Q8H50TMxPEp79G45k
         zHIlJkYxKWfNd7t7fcXvDA9XPeCR0imm/uYYy9fovDrf11Bspby8OG7kKVuRVeZs95jm
         U3gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=mMOlfiNeriS8dHk456D4i2uPqqdGUdRNA/UjahArgCQ=;
        b=UcNvaOc8Sk77TBCB7GCOM1oI8g10P7K4n1unV9ymPEHLbnkxvmk6tkBK48h5c3kt4z
         ZWJnlZ48uLFAg2SnQvttpcKLaD0imHXSfo/FiKjj3BIWFOAcgth2lkLd3rTDXVWP3C4c
         +S2oejSQWypfExcZe7XFjtlEtXmBWuiIpivLG/CezU3IkG8KGx8lmQFGd8g03A6nk5pa
         H73zvqPzKoKXvpK+oZKVBU+fpA30k6QEKpLtyjI3XlYlriOFWamEI28FcU2quJthdmO9
         fFLXMXEe2FJoPeXFwe2yexlK92zDbmXZphtQOpIhzMsa3BDmYVCLHoJI+uUuXAmM7pY4
         Ql3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=h3LHlMdQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 83si538670yby.327.2019.06.06.00.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 00:44:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=h3LHlMdQ;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf8c4430001>; Thu, 06 Jun 2019 00:44:04 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 00:44:04 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 00:44:04 -0700
Received: from ngvpn01-171-236.dyn.scz.us.nvidia.com (10.124.1.5) by
 HQMAIL107.nvidia.com (172.20.187.13) with Microsoft SMTP Server (TLS) id
 15.0.1473.3; Thu, 6 Jun 2019 07:44:02 +0000
Subject: Re: [PATCH 12/16] mm: consolidate the get_user_pages* implementations
To: Christoph Hellwig <hch@lst.de>
CC: Linus Torvalds <torvalds@linux-foundation.org>, Paul Burton
	<paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, Yoshinori Sato
	<ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S.
 Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, Khalid
 Aziz <khalid.aziz@oracle.com>, Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras
	<paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
	<linux-mips@vger.kernel.org>, <linux-sh@vger.kernel.org>,
	<sparclinux@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-mm@kvack.org>, <x86@kernel.org>, <linux-kernel@vger.kernel.org>
References: <20190601074959.14036-1-hch@lst.de>
 <20190601074959.14036-13-hch@lst.de>
 <b0b73eae-6d79-b621-ce4e-997ccfbf4446@nvidia.com>
 <20190606062018.GA26745@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f7ccf08d-b269-c5e9-7a86-0b5c6176a7c3@nvidia.com>
Date: Thu, 6 Jun 2019 00:44:02 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606062018.GA26745@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559807044; bh=mMOlfiNeriS8dHk456D4i2uPqqdGUdRNA/UjahArgCQ=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=h3LHlMdQHamD4aUSwPzeTds3U6FI5EEYLkWJ4CyKjK6e+LboNBSAbcSHpVs2ab/a6
	 z9eQd8NbRaW2yWXClwhhhoDwI/Bg8V5MhP9jYxjADW4on9H1UbzwmFXUvBa2QQc0YP
	 3BZxHfWSY+4OVCEed52WcnU8jW1oCIuqanuBVjnZxsQlD1tSrzhAGFH+mkQujZW9MV
	 3WEIf8zeYJc6hdtRCd3LqEJefWg6Q5t5xgsR/hrqbzz+0tbm21c1EGeCCpOskwezjW
	 2zGjfIhkSG9BX9aupNObBuuWNlgR4cVZm3rSLITraOByP9C918Zm94j22vnCvn0l3v
	 eA+GgKwaIXi4w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/5/19 11:20 PM, Christoph Hellwig wrote:
> On Wed, Jun 05, 2019 at 11:01:17PM -0700, John Hubbard wrote:
>> I started reviewing this one patch, and it's kind of messy figuring out
>> if the code motion preserves everything because of
>> all the consolidation from other places, plus having to move things in
>> and out of the ifdef blocks.  So I figured I'd check and see if this is
>> going to make it past RFC status soon, and if it's going before or after
>> Ira's recent RFC ("RDMA/FS DAX truncate proposal").
> 
> I don't like the huge moves either, but I can't really think of any
> better way to do it.  Proposals welcome, though.
> 

One way would be to do it in two patches:

1) Move the code into gup.c, maybe at the bottom. Surround each function
or group of functions by whatever ifdefs they need.

2) Move code out of the bottom of gup.c, into the final location.

...but I'm not certain that will be that much better. In the spirit of
not creating gratuitous work for others, I could try it out and send
out something if it looks like it's noticeably easier to verify/review.

thanks,
-- 
John Hubbard
NVIDIA

