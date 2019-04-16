Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6EB4C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4E972183E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:33:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="D0VK6UGY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4E972183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 352146B02BC; Tue, 16 Apr 2019 11:33:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 301AD6B02BE; Tue, 16 Apr 2019 11:33:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F0986B02BF; Tue, 16 Apr 2019 11:33:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD5776B02BC
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:33:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u78so14293362pfa.12
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:33:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=bd3kFaiRh/kYQ/VA2Yue7fpxsO8GiVa2yaT3r9nUGpA=;
        b=uM5s7pzAQY2LL0+z+801ZsjdUBpX/+rOEbpzsJpByK4Z0LCJBi8OjXeB188NKLUOxy
         miujUeNkrk1iIvbCiRVfSdcbLxXr4aX8WSYohxaPUc01+QVX06RF6QYRU6EjDBtW5FuN
         MfEUWHttHyw0NhdLgDxszy6yqg6moIrNt/w6Y3ImCzuap35HcT1ArcKmrQJHdMYE8quQ
         0XhTX6XqYqXz4B3SGB1jHfBC1oJAugHJDvzVP7ZmhNlWtrw9bqnP9u4OdqdK8/hysmHf
         krAIDBuilKsWUGAZVPjlA05z4kJ+QSB433WQkdaY3wqPVBnt/Rqp5YGGxPbEnYV1SRLe
         oKBQ==
X-Gm-Message-State: APjAAAVU1HkjaCo6V2NjEKZl1g8pBitcktfgAKBAb1mTLointCqXfabO
	33atmamUGD4lCsr8MnYTxYo2l7bPpULNH5BMlzco/t/u3XnK4N1msVOygLa3eyXTzwheQctSiWV
	ZB/ELwDS4pTjv0yFUmdINez+QhJPcVUG5qwuzHUc33cKvJbQxOPjl3XE7MGD9oNyVkw==
X-Received: by 2002:a17:902:801:: with SMTP id 1mr7487947plk.14.1555428834564;
        Tue, 16 Apr 2019 08:33:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyL/MVVSzeKGBTpBU+IEtWBmOCFfKCO1I3cGhxlC52A3WwlU6WAjhukdxD0tWbMFxs+sIOT
X-Received: by 2002:a17:902:801:: with SMTP id 1mr7487875plk.14.1555428833784;
        Tue, 16 Apr 2019 08:33:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555428833; cv=none;
        d=google.com; s=arc-20160816;
        b=ljuPa+3z+uI4RuNKo2ah+xkuJzY7kGJaNVzqh9cXF7j2cXNu4Hjddy8W8fN9pUSUl9
         LHIgTzMBCPhoV384RNL74829Ax0nRoDefHAvu2/2AHbllH7GAeyjvpOr5oYYVS9BuJrT
         Vxn5D/5nwhkny+z+FwDc72kePWD9K/k714EeILUozkQKEC3yht6X0M7kmbDJ9hA7Lg52
         HIyq5F+kapSAOM+lreqn92YLCXarXHs+xDta7NBnjYr1bglxYpKKKdHTfnO5iZjgf1/J
         CWzxkKK1B1fNVlkoq3rEPTxpPYRsu2cthktVI1Nx8ay+ou0getNKzW3cYA++AEM90VNb
         lctA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=bd3kFaiRh/kYQ/VA2Yue7fpxsO8GiVa2yaT3r9nUGpA=;
        b=f699dAae4ieuZgoz+I1NFyDesANq1F//Ez3z0Lv9G7+obcpIzvQ6Dc1l3StuHYG07r
         sjxdDs83aDelW1iBeAsgpvR9hFiiNhSTNxNbciOYvNU4G0pgvqgrmYIWwBPsfROEL3cW
         qMS0Ji9fvLBqLeJY2OyD/rD4gYzr4Tx6LaJ2NjPJrJKrEgi7+pV/PFvSuBLXn13GLbF6
         iUB/Wuew57JrUIidsVw2zVY1qkXQABslI81SaNve1NP87Mdgj6hBLgX1Wxa31va4728K
         NdCVpm0wcl5CmyNnmIVCxNw1ALHQo37qYZfLiBfQPsV2F9vlyUVfcRDyCc454pshKVZu
         Lh/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=D0VK6UGY;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 1si22715435pls.222.2019.04.16.08.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:33:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=D0VK6UGY;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cb5f5e60001>; Tue, 16 Apr 2019 08:33:58 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Apr 2019 08:33:53 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Apr 2019 08:33:53 -0700
Received: from [10.2.163.24] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 16 Apr
 2019 15:33:50 +0000
From: Zi Yan <ziy@nvidia.com>
To: Dave Hansen <dave.hansen@intel.com>
CC: Michal Hocko <mhocko@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
	<mgorman@techsingularity.net>, <riel@surriel.com>, <hannes@cmpxchg.org>,
	<akpm@linux-foundation.org>, <keith.busch@intel.com>,
	<dan.j.williams@intel.com>, <fengguang.wu@intel.com>, <fan.du@intel.com>,
	<ying.huang@intel.com>, <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Date: Tue, 16 Apr 2019 11:33:48 -0400
X-Mailer: MailMate (1.12.4r5622)
Message-ID: <960F3918-7D2C-463C-A911-9B62CD7E5D83@nvidia.com>
In-Reply-To: <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <b9b40585-cb59-3d42-bcf8-e59bff77c663@intel.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_57E8BCAB-6C56-41AF-B3EE-B97124E8B1E5_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555428838; bh=bd3kFaiRh/kYQ/VA2Yue7fpxsO8GiVa2yaT3r9nUGpA=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=D0VK6UGYELnYUHygSl0eyMobF7vDjJmVInGEQAE2b5AzTNcYNwrcir9jTW721dQLC
	 KlUSOECLHZwckWMmSvAxeGJShPtqiUdvY3C+934PK2093dwETWwTj2HdblVYf7r4b9
	 9+Byh4SNduynLz6VwrONfBRZjT+A1eiiEG9UhWGoVhVE5vavKnhbf+7sMcrOVrzKoA
	 Fxj1nlC0vLEQa9ZBE1kpwF/B1OPnJVl0MLhCtVAy4tkUuntOP9oBsYMh2NKC3F8j2h
	 xtlyM7eQ/HXU+a4kdgkS+puU8YmaHZScYRL8Xs4PSVa/ChVR8wpdSzHYKyneUGf/KD
	 sml2IjdsrCIaQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_57E8BCAB-6C56-41AF-B3EE-B97124E8B1E5_=
Content-Type: text/plain

On 16 Apr 2019, at 10:30, Dave Hansen wrote:

> On 4/16/19 12:47 AM, Michal Hocko wrote:
>> You definitely have to follow policy. You cannot demote to a node which
>> is outside of the cpuset/mempolicy because you are breaking contract
>> expected by the userspace. That implies doing a rmap walk.
>
> What *is* the contract with userspace, anyway? :)
>
> Obviously, the preferred policy doesn't have any strict contract.
>
> The strict binding has a bit more of a contract, but it doesn't prevent
> swapping.  Strict binding also doesn't keep another app from moving the
> memory.
>
> We have a reasonable argument that demotion is better than swapping.
> So, we could say that even if a VMA has a strict NUMA policy, demoting
> pages mapped there pages still beats swapping them or tossing the page
> cache.  It's doing them a favor to demote them.

I just wonder whether page migration is always better than swapping,
since SSD write throughput keeps improving but page migration throughput
is still low. For example, my machine has a SSD with 2GB/s writing throughput
but the throughput of 4KB page migration is less than 1GB/s, why do we
want to use page migration for demotion instead of swapping?


--
Best Regards,
Yan Zi

--=_MailMate_57E8BCAB-6C56-41AF-B3EE-B97124E8B1E5_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAly19dwPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqKA9gQAKI3aZgoIkLFQzrv57dHqxIAVc6GgDJWTE+Z
mryinojumKMAcHTp9ZkvGszdgq+Cgt7NKecFtL1pVzue6/Gy9da8zzigfXw7el+T
lfAWXZiV7WcRXBFhjvvYrngfJiZmlx/mFjt7euWS4dBGDiDj3Xn/Zaj0h6S+DcNS
SqAKuhk1xIQPPXFnnkZTbSY92bHL02txpYYSd2R9rRyyTam2hPKqzyFueCZhoFlv
zcKnaLZ0nmx/GJL9MJiIxXc5Upcbypa+y1VP3OZkh9sbcUcRAKcP/2AISMz9+TsJ
IDnDyWsV6pO1hpAayFk9pVSuu+wZdJ2wf1anA0d+S4KygqLkq9fynRvUqP2Ch4A2
kM48I4UaeS/c4l8lACoBAoa68edg2h+2Z+x33RM1gtfNNZivo6ZbWfNgg2MObeBZ
IaDhwPFV2rBlM6Ol5KLMt4a/Xz0uA0aEj3cZ4udB3q6bQqtbxEvkDL7ydQ1CbcG4
LaoEdonPBTsYwbvNE5g6Ly1b5LjGtdHLL1fSnF5JfIVPYl4d0EIa14qITDqc+j+Y
C4JYyMbDfxzUvLtXT3B8CC2UyMEp66DKrk3Jd9doVaetfi6clonUuKzymLU2nc9M
DU4L+APcbW2Wt6Cud+GgRoNfm2sK7YYRu+eul2YFHLfw9Ecz/uQoNK15SIsJqUcg
WFrORWyW
=yfKR
-----END PGP SIGNATURE-----

--=_MailMate_57E8BCAB-6C56-41AF-B3EE-B97124E8B1E5_=--

