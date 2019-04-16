Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4830C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D8252087C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 16:12:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Jytk2YQA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D8252087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFA346B027E; Tue, 16 Apr 2019 12:12:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA79C6B0287; Tue, 16 Apr 2019 12:12:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B70DC6B02A8; Tue, 16 Apr 2019 12:12:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79D1B6B027E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:12:39 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id w9so13655569plz.11
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:12:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=0qG+gTlRQll235954BIuhS7cER94zkwgbFGR8CUs9fc=;
        b=KIpFtF6EfePN1aRZRgVLHsSzAOZY0D4tFhFgqC/KYt4/7SYC5R2z3UyYDm6Qg5EQlb
         EHNWFzhCsahenWUMGMP3NUDoCeItNxBH10Fc1ks0BJYhsRPwX/32boiWWdNw75pJnNtt
         LUkjlhKQ17IkOs3DOALovSRWQGYVtbNESV6Badx9MeWVXIYaivzE2He1RoK99ckXgrk0
         9Yz4wFgm+NxuzU3XOj7HnPlYSgyGXqeuN7GahsnNwkqq31wYaZw1v2wbW0fxHBJnx8aV
         x/QEr+igS5xYecq8kLjLcRAxauuc3taR8K4T/v+lnShYUxAyAqk/KeF3zmFy5qdji/6T
         pqrg==
X-Gm-Message-State: APjAAAVo6LL+OFsmmiAqtgFdjoSC6oA5YCpZDOJ/QCBr8zMFaLWfNsz/
	STYxmq5zyrsNY/O0q6WaXuxX7p37Rcl7fKzEhf0b81g41NI9TssjEOoGa/RA1LD1tBo7C0ET+av
	7duIodPSdK2wyG6ewQ8UPj7DaYLxpHcNNVpxKmcVla2V+8eGa2zlDSr3uigPIVMvcDg==
X-Received: by 2002:a63:c54a:: with SMTP id g10mr77023717pgd.71.1555431159062;
        Tue, 16 Apr 2019 09:12:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxA4+fq4w0EKUiyXj7TW8QN09IExJ98s5oLL+YmgqZAC0tria6K0sz7DhbZCxgqnzMq6btM
X-Received: by 2002:a63:c54a:: with SMTP id g10mr77023660pgd.71.1555431158391;
        Tue, 16 Apr 2019 09:12:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555431158; cv=none;
        d=google.com; s=arc-20160816;
        b=GX0hVQ0a7P1o37HDgladxNq2yasCjeFCOjPs2iJT6fs16xUnvG6wSYwUpVllezUcEV
         hu7yOkMJcqFavd3TbKy9i8zlcDJjRoQOKUi5MQavfoJdDTXesIbcz3GWeL0dDEDmumqx
         mAMpV9TBhJ5vCPSN9eQqRq7VcGhra9TGn3Wzbb10XO5sc3D5LYeIGRNQEHShhzZnjXU8
         tZGEnDFOR3mSGJujdMudXOJZdY4uIGVZzBJhU/cKSIXOOMxxc2Nxcilt/oSJ9Stbqv3Q
         L+SHCjDrGqU8JhOPBpkCK4Mzsx7nxnTm91MQ/UUSRRetnsId8Q1sDOeITRUkZlZTMxnY
         3VFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=0qG+gTlRQll235954BIuhS7cER94zkwgbFGR8CUs9fc=;
        b=dMwD535TYn7JJrVCeyysh1Qdl0fgIpBfGwKc63mKelqvHbmf/aDWtmpsDwm+MSUy1P
         lxmAK+by/i8sAdVv0x/sReYEapgTeXqf8e1Z/GQdXp4n3Mk1DwRWb+2o4iu1OKYyCTzX
         c5RbX/REGWdVQumFAB91BR5gxk6wHYRs4D1rUutaEq24bZ2szh7FVCR6uqCGLfWXW5n1
         ai9II6nsi8HDU6LKSmA7SUOZGjJHmKVNZWt9Zf1z3p8mOzL0SN3Y66VlAEAyCZpWAi0v
         iHCbDtRKQLfnfk5mK9DpJMP8yjzgY+I9jddObAkyf7xCtcNWjxY7pb1k9nb8n4vQ3up9
         gW5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Jytk2YQA;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n7si48833057pff.190.2019.04.16.09.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 09:12:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Jytk2YQA;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cb5fee20000>; Tue, 16 Apr 2019 09:12:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Apr 2019 09:12:37 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Apr 2019 09:12:37 -0700
Received: from [10.2.164.200] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 16 Apr
 2019 16:12:35 +0000
From: Zi Yan <ziy@nvidia.com>
To: Dave Hansen <dave.hansen@intel.com>
CC: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
	<mgorman@techsingularity.net>, <riel@surriel.com>, <hannes@cmpxchg.org>,
	<akpm@linux-foundation.org>, <keith.busch@intel.com>,
	<dan.j.williams@intel.com>, <fengguang.wu@intel.com>, <fan.du@intel.com>,
	<ying.huang@intel.com>, <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Date: Tue, 16 Apr 2019 12:12:33 -0400
X-Mailer: MailMate (1.12.4r5622)
Message-ID: <027AE219-8C81-47DC-A241-4209C3F656A0@nvidia.com>
In-Reply-To: <63514bdd-313b-d42f-e582-f8cb350d0b35@intel.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
 <960F3918-7D2C-463C-A911-9B62CD7E5D83@nvidia.com>
 <63514bdd-313b-d42f-e582-f8cb350d0b35@intel.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_D57647AE-4DA1-4C9B-AEDB-C24F26D9FE9B_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555431138; bh=0qG+gTlRQll235954BIuhS7cER94zkwgbFGR8CUs9fc=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=Jytk2YQA8nNJaUP8MgkVSmxdjPUeN9yqd1byaO9hk5gSDhMap8lTMNVOHtgdc1t4A
	 tdw0Ew8E0ETmE3zhpdhDUURSrICP3fjpQnG+16DTk75JmSVaUMlrgKFXdpbRMPo6fu
	 JxU3y7l9J3B8fFCNUgzpHhHUIg3oWhWwmmncSpoStJUmfg87NzfyByFXbbPMG1qJNy
	 2/JtTWTVQrpqC/6vbuArQjJX4nl2VCGdILF8gjxMdqzEoQBPLkIHfbW0MsbN7tqzp9
	 YS52pK3hp/dC5Cs8PTS2pnVOuGfmzhZCcsVRg5aV35F/qYhCrNy0apuKbAvguz24wV
	 CFrezbmidOTcw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_D57647AE-4DA1-4C9B-AEDB-C24F26D9FE9B_=
Content-Type: text/plain; markup=markdown

On 16 Apr 2019, at 11:55, Dave Hansen wrote:

> On 4/16/19 8:33 AM, Zi Yan wrote:
>>> We have a reasonable argument that demotion is better than
>>> swapping. So, we could say that even if a VMA has a strict NUMA
>>> policy, demoting pages mapped there pages still beats swapping
>>> them or tossing the page cache.  It's doing them a favor to
>>> demote them.
>> I just wonder whether page migration is always better than
>> swapping, since SSD write throughput keeps improving but page
>> migration throughput is still low. For example, my machine has a
>> SSD with 2GB/s writing throughput but the throughput of 4KB page
>> migration is less than 1GB/s, why do we want to use page migration
>> for demotion instead of swapping?
>
> Just because we observe that page migration apparently has lower
> throughput today doesn't mean that we should consider it a dead end.

I definitely agree. I also want to make the point that we might
want to improve page migration as well to show that demotion via
page migration will work. Since most of proposed demotion approaches
use the same page replacement policy as swapping, if we do not have
high-throughput page migration, we might draw false conclusions that
demotion is no better than swapping but demotion can actually do
much better. :)

--
Best Regards,
Yan Zi

--=_MailMate_D57647AE-4DA1-4C9B-AEDB-C24F26D9FE9B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAly1/vEPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKz9gP/13w9KgpJ81vf8ZHTOonc/BRsQrT+aFB48qF
eFtTeeHBW7Rr5NWBjbAzFb9SkQyWCCRHMjf6wv0qqy0NWAzAGZISf5nQDfz/++vh
j9hC7Auj8moROyrh2uXoyUGfYiRQozS2xP0idz+EGGT5G2UKRdSFLLEW4KxrAqYO
rXezQTPLeHv4exlslF/eXuod6miV1Sq6NOSy/FbrgV6CHDPwM4NL6mBeQZHfM3Xa
mF0CtvRhYjDR+dO/SRQkpJYs1+GbADzH23BT0wx7nUQ3mUciO2rgdizHePQllx9I
AmDxgjjkiFjWObnkWHx5hKZ3i1Uiu9nislABm7oPsAK5qa4TvXsjHthuet5l4vc6
s4m9aMI0ehz0yI4hGKUUYnRoWTPcbfvni8NuFfdmBxmpIgAmaBd6LS7WSbIF9Df2
V/w0aVSI8mDHVl/9Fa+pVZQ4HJTymPD7BkNphTF692VukYVMDMaQCne3rmXotEe3
T4Bs1MYY13ezs3VuXKymzXjjiGpML+nGBzvzj9s/Itwhk2jQXIUw2sJDaTlD6fL3
/kbavQFu/jmpi6BF76CVSMbScnGO0hGZ+Gxhp/L55BO35cbLI/eBzbaNDNqe0z2O
Cm4PhLlV7cOVUdaVGkkWmJ/t/NEfPtuXP85m8Suww6hfSmGBT/G/idOFIDylWBqs
YORU6ksO
=Car9
-----END PGP SIGNATURE-----

--=_MailMate_D57647AE-4DA1-4C9B-AEDB-C24F26D9FE9B_=--

