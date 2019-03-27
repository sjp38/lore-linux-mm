Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56188C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:00:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04A042146E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:00:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IvZHSl+t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04A042146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86FFF6B0005; Wed, 27 Mar 2019 13:00:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 845DA6B0006; Wed, 27 Mar 2019 13:00:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 733DC6B0007; Wed, 27 Mar 2019 13:00:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 390466B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:00:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id k185so8221186pga.5
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:00:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=Io+E5uEESZPp1e9HALilVFuhRQtmhI/36F2P/dMd/ho=;
        b=G2yZ1GopqH42Og6yIhY71YOQYqvbJGOwSgNwgJJPhJBz/l517N7hCqNEM8g4YDo+6y
         d5LS2n4tin7b5rIfA2Sj87tB9apjX4UcYSAFNRwXG+0xJGna01sPiZC3IwKJjhJGvVgh
         TSw/DbEe2qr7VsAQMoya+yzvTXSzMOR/Kl5ygop8x2G1g6vAYxabVXsYjC7wticG+Rpi
         HSDy4z2FeBegwTxmTTUM8RPNfbF+1j+ePGoJ2P6sUauD/xPy+nSvHQL/JGkHFZ23Kznj
         IBK5xRzR5WuXKKpr6P20iD/Z9TUK75u2ySxEHj0y/HSP0E/t2Rhm5hbEmZBpvS9vZ5DQ
         O8pg==
X-Gm-Message-State: APjAAAXdZbOoZc8B/9g0kQE7lVXvIPL6YmvWrbXm5eNX/bBmRmJvVx4s
	CUdCe9pnrspKK1gV70HjCiux886u8epDh6jriBtfLSRp1yTDpNJ3jv1/wBCFzzysIeX4DRBS3Ei
	QZiMpqkkTF7z4pQfpWxLjxTzfkwwy0yg0ibkDL/XJPbFX+cOtSIbJKYxEZHQ0ns2bBw==
X-Received: by 2002:a63:78ce:: with SMTP id t197mr22263933pgc.314.1553706054461;
        Wed, 27 Mar 2019 10:00:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj6MdVq6PU7fH/96aaJw78GL5iEQo/KRfV4Rm37vCmMXyf/z11L9BmLJeQl/4EAXaR0adX
X-Received: by 2002:a63:78ce:: with SMTP id t197mr22263831pgc.314.1553706053448;
        Wed, 27 Mar 2019 10:00:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553706053; cv=none;
        d=google.com; s=arc-20160816;
        b=RdLcugBuhw8xXQY5TU7wDGy9uek9BoIu89yAum4sqb10WlC+kQfWaXl/v/Y+a41Fw5
         EzLM0NktPLAtrU1zuGkAVumKMDiDoPTUBVaFOpM9rBwUalcZnTuawSPmzf+Dzcg3nT27
         l83GSWAag8R3n0Fp7UWPBzvgWHEKjxQh857ot5poB5cHw6F3Ud1IijrtCFrM/GXs2ZKf
         T1VK/NafIwNvXvpWlBsJVs18yJU+2d/W1YOq/lkjkg5zPTHfKSo5LraDq3ddtt8asSou
         cCEJuenhzbQaIXRXE63lIqMxyT5zinhgU9J+RozxKIAmvhWtspHXBvLxQioKafC9BUxt
         ot8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=Io+E5uEESZPp1e9HALilVFuhRQtmhI/36F2P/dMd/ho=;
        b=lZQAuVYW2RdFztDkfhhsI4spy7TDQOwi9O/YnCtkYJ7+I20xD6BrOptRWpyjtS4uyd
         GWeralNYqDTTVOBfbCBvZcmmoEvw7uJIutkdsLGfOMeHNgjdPjEFFOYoJbTmJb95prcy
         dbFATI4qQ7yeyHmon+Pqt6fluqK3AR3RYz1lWbVrfjvnnc7ZRsKqurSC7mPjyRtJ4jLR
         Ch0KE44l/Yx452CjX0YJfZpKt0QTNrZ9WaPn/K3nWQYdboLPaVy+Q/3dVgJKBywm7xgW
         ivaYooRz3TVzTY9GtfiJiRVzjdR1q/7wx827KNe6azdhvzAKy0Qz7egEmcR+FPCjxGb+
         oTHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IvZHSl+t;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id h20si17825999pgv.388.2019.03.27.10.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 10:00:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IvZHSl+t;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9bac420000>; Wed, 27 Mar 2019 10:00:50 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 27 Mar 2019 10:00:52 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 27 Mar 2019 10:00:52 -0700
Received: from [10.2.164.169] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 27 Mar
 2019 17:00:52 +0000
From: Zi Yan <ziy@nvidia.com>
To: Keith Busch <kbusch@kernel.org>
CC: Yang Shi <yang.shi@linux.alibaba.com>, <mhocko@suse.com>,
	<mgorman@techsingularity.net>, <riel@surriel.com>, <hannes@cmpxchg.org>,
	<akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "Busch,
 Keith" <keith.busch@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>,
	"Wu, Fengguang" <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
	"Huang, Ying" <ying.huang@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Date: Wed, 27 Mar 2019 10:00:51 -0700
X-Mailer: MailMate (1.12.4r5622)
Message-ID: <2C32F713-2156-4B58-B5C1-789C1821EBB9@nvidia.com>
In-Reply-To: <20190327130822.GD7389@localhost.localdomain>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_FDAFDC66-07F4-44F7-9872-93BE2994CEDA_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553706051; bh=Io+E5uEESZPp1e9HALilVFuhRQtmhI/36F2P/dMd/ho=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=IvZHSl+tgFV6D4idQxZTXdUfHMcBl+ShUvrE5uXkfGG4Db3DX2DHDQh17O39LV+ce
	 Ufm4OpM6vpWU7wTDnsIDvtuihTe+yCyZWkJMVuXSaQii6g+GCdajD7ejGKrXwOWFvH
	 R2Tun0CTNZO/Vkemb6HWBLBraOi3aIdjCFOLV4Cndo0UtQ8Nk7AxveDhV+p9tD2iqm
	 /atJ0ZPWGg+7QVN+2YnXt/yrnwtHVUneUR+WzjMOoeyKie6OewIkspWPJkeuUCLiCo
	 EDAoZJpQJlva3Fb6BtW0Obq1cnGuDCzePtOcgsTLGk6KA/RQvAzf2JCfjvBdh5q4fr
	 7dbfuZb7tL7zg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_FDAFDC66-07F4-44F7-9872-93BE2994CEDA_=
Content-Type: text/plain; markup=markdown

On 27 Mar 2019, at 6:08, Keith Busch wrote:

> On Tue, Mar 26, 2019 at 08:41:15PM -0700, Yang Shi wrote:
>> On 3/26/19 5:35 PM, Keith Busch wrote:
>>> migration nodes have higher free capacity than source nodes. And since
>>> your attempting THP's without ever splitting them, that also requires
>>> lower fragmentation for a successful migration.
>>
>> Yes, it is possible. However, migrate_pages() already has logic to
>> handle such case. If the target node has not enough space for migrating
>> THP in a whole, it would split THP then retry with base pages.
>
> Oh, you're right, my mistake on splitting. So you have a good best effort
> migrate, but I still think it can fail for legitimate reasons that should
> have a swap fallback.

Does this mean we might want to factor out the page reclaim code in shrink_page_list()
and call it for each page, which fails to migrate to PMEM. Or do you still prefer
to migrate one page at a time, like what you did in your patch?

I ask this because I observe that migrating a list of pages can achieve higher
throughput compared to migrating individual page. For example, migrating 512 4KB
pages can achieve ~750MB/s throughput, whereas migrating one 4KB page might only
achieve ~40MB/s throughput. The experiments were done on a two-socket machine
with two Xeon E5-2650 v3 @ 2.30GHz across the QPI link.


--
Best Regards,
Yan Zi

--=_MailMate_FDAFDC66-07F4-44F7-9872-93BE2994CEDA_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlybrEMPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqK/twP/3lcO6kKxaHl/38KpTngJX//h7UJzoANsSrb
le5gVdUnBGP9KnFWyltBDEbNggucShHm+U5hFBvrkDzY/fO8BJTM5ypXiPxDr7h1
5XyvCJuuBtSE24X5autv1xF4QKIHTb69N9uojoMy4WYyQmnuuuMTC6vFICUinQuL
pQHHtx2VxINXRVPOcW6XMYxBopW5+MuYyXtFRrT9+tEQvJ9Fw3Gwg0JwuiEZx9Sh
aUJhOrg+43Lfs0ES0i31Mw7KD+csr/uii+HVdOT/FBEtge8QvxlV2FxBnINkpHa6
xVo5cWoNbo++rdpobmnOsjQvJ01WWyoaTwvHOITU5zmH85IVraI0N7G5PsCMuexB
Hvvndlo+WNcGTvF3YgQgLb/0xRjqT77Jwli7rXMNhihXLyw5cZrGTwueEJV8saou
oXDw7WzLUokCPPuhdicKt8uQ+encxv20TxGxZrPCu9hL+7+s/DLZ3BhwptTkvhbF
TQeGbfbCKTlifJ3AqSi1041vwxTz2C0moUz5kWIgf2rZG/NlM8S6AwPv2hHTxzLZ
PEtY7fdJCEYLk5DPkkwBxpiH/JM/yyQLH0WOHYpbxWxtR/5CMnE+YR1JNL2hKs7e
kOalkTxRURDb/3+uGUAPWEY+VWOhzU5DIsO28zXopEQCWB+sVYinCLhUdgroRgAD
Bx5LaaKT
=HFOS
-----END PGP SIGNATURE-----

--=_MailMate_FDAFDC66-07F4-44F7-9872-93BE2994CEDA_=--

