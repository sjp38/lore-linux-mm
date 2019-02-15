Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11EBBC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD771222D7
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:20:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ogWR0BCu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD771222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57FC28E0005; Fri, 15 Feb 2019 17:20:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52F438E0001; Fri, 15 Feb 2019 17:20:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D1108E0005; Fri, 15 Feb 2019 17:20:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08C5A8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:20:41 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id p62so6961046ywd.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:20:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=PVlYGjyWaFVWJioBZgBkG+3PLaDi4XJfqvkkL2DVWxY=;
        b=YAa3EhPIFsPg7MJ5vfhnvc0i5noawr6jc6e1bft07qgsyBJu+pYV90XqHTMvON17Rw
         Nv82KC5exeG4RYVBcr68mA7Bx8P+xSZDsEXlnp4ViDoS3gNnaMWxnb/WLHE2I0QtbMnK
         FpgSwraNR0mWjBFDmCSEfC9fUoADqZJll3sBpGfAX8LXxzAqohPf719GG00Aqo/sXLyv
         aHh9fU2VYgXtWcv9cgcnPLLXLsjgbHI4Jmu2YrLBS/lgGCAOTAVwOS1dfDWPwVo8xpxx
         k9k6DQrbB5It1YrknhWIPDBAImZY0bMJlH5y9UHc2CZ+qiZFxiIPdLMT6WRL7GJVWlHU
         21hA==
X-Gm-Message-State: AHQUAuZKxtTnd9xikVzgyb2o96sZRGYp6s/iLImFXm92E2AXpTJ4SSV5
	YKsMZ79BJMY/hfDXYg50rdwuJXWYCOzyn+RIY2cf178cSDO1r3PKzPaxkAJpGkNbkxQhSJmg8cY
	WFFuo8D1o+gWiBASJBNV78CW0lQQT/Y+4i5WeZpPW1s109ZUzRjHxuV7Krclnu2Brcg==
X-Received: by 2002:a25:ba8d:: with SMTP id s13mr9857314ybg.332.1550269240680;
        Fri, 15 Feb 2019 14:20:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ2PPORtCx5gXy+K44DqqDBS+MlldqbQHy/ZcD6QHCVDfcRH5iNPqekeTTImxqCwMyt+XRN
X-Received: by 2002:a25:ba8d:: with SMTP id s13mr9857265ybg.332.1550269239776;
        Fri, 15 Feb 2019 14:20:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550269239; cv=none;
        d=google.com; s=arc-20160816;
        b=NkwZT1lzxvZwlXIYDsrsKtr4qnN0yTX2YFuT6/N5h2qWyAxcMCdge/b9doTeSjNHH2
         mbzHi3vqHTSBM1WQ882RbrfhlrmUp49g1LZtqUKAF6EbzTL2FJEb2iQoRe27n/D1acV1
         SMBxC+qxORLTHUCjJJgKSpUu0RDljjVrSfy1WXBwrMAD681bFdq/TulruGqAFjGgL+rG
         RX1Qq/6lZVb6wazb3kZO7L2zidAO5Gmitsm6FFZqn/GEWwTr3FDkssHSNVD9A3isGlh5
         FMPNnEcYeXM2ff1qbJ8vLdTbD8mIpmZXC2z6LywWuRHL83wB6w73HZ3qBdypNBGNNcc4
         ikvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=PVlYGjyWaFVWJioBZgBkG+3PLaDi4XJfqvkkL2DVWxY=;
        b=Trdgbsl3CNCzhRbaoPbidDAiU/txOMzFs4lCG62oLJM8nrnzTy2uF/u1eUImHnCcnc
         ETA7Km6nEVFqSJMIyMMwkHuC2d4OK3EnoGTLa3UTUeWQFIzbBQjPjhfkqY3m6shute98
         Xoh41JtIVoWxbXoorwGgB4Fb2nXozaoD4KfqJPKgdQh+NexKLNNoI602svKS+XRteBR8
         /1MyD7qy4fueE3POZZo+49SeNpFRN9qsXd+C4OVy52gUSUb6eqSCqyEIqpHeSBic3Zml
         RbiuASdq46bdayd0rVb1fFfKEIkhbc2DOmOr++KHP5QzoF4UN7Kpg5AmTx5Nyv0DkPbE
         iemQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ogWR0BCu;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 185si3855753ybn.262.2019.02.15.14.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:20:39 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ogWR0BCu;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c673b3b0000>; Fri, 15 Feb 2019 14:20:43 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 15 Feb 2019 14:20:38 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 15 Feb 2019 14:20:38 -0800
Received: from [10.2.160.210] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 22:20:38 +0000
From: Zi Yan <ziy@nvidia.com>
To: <lsf-pc@lists.linux-foundation.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Michal Hocko
	<mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox
	<willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A.
 Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Mike
 Kravetz <mike.kravetz@oracle.com>, Anshuman Khandual
	<anshuman.khandual@arm.com>, John Hubbard <jhubbard@nvidia.com>, Mark
 Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>, David
 Nellans <dnellans@nvidia.com>
Subject: [LSF/MM TOPIC] Generating physically contiguous memory
Date: Fri, 15 Feb 2019 14:20:37 -0800
X-Mailer: MailMate (1.12.4r5594)
Message-ID: <CEDBC792-DE5A-42CB-AA31-40C039470BD0@nvidia.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550269243; bh=PVlYGjyWaFVWJioBZgBkG+3PLaDi4XJfqvkkL2DVWxY=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 MIME-Version:X-Originating-IP:X-ClientProxiedBy:Content-Type:
	 Content-Transfer-Encoding;
	b=ogWR0BCuJXewZzQEbJpYlL6oQOPHs3TDFPbVoaDaQfS985aojrx16wa56IBizh27Q
	 W650rtKEZTBrMGR3NmV59/2JI9QFULJ8lNlkvmq/GvvhmDe5oMNGjiEsk/Gs0B4xcB
	 0tvVG0B1FBs/z0ynvpN1lT1F8jz2MPYNDa4qM+hFaGG0ZiQuCkq+aiJz8i3WerXaJM
	 91rderrFOSmUTTdB9kXVGlKcGeqsseaHFRhyP49yPEzT4LNVH2Jm1v1KuAFrna9S/4
	 7bepyHG4HtcPv0/PbMEYRmU3+He3k/+6BVAM/2SOB+KTg9g0NTwahvWZUi0Dz/gvVg
	 C3Fr5BaFr5tgQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The Problem

----

Large pages and physically contiguous memory are important to devices, =

such as GPUs, FPGAs, NICs and RDMA controllers, because they can often =

reduce address translation overheads and hence achieve better =

performance when operating on large pages (2MB and beyond). The same can =

be said of CPU performance, of course, but there is an important =

difference: GPUs and high-throughput devices often take a more severe =

performance hit, in the event of a TLB miss, as compared to a CPU, =

because larger volume of in-flight work is stalled due to the TLB miss =

and the induced page table walks. The effect is sufficiently large that =

such devices *really* want highly reliable ways to allocate large pages =

to minimize TLB misses and reduce the duration of page table walks.



Due to the lack of flexibility, Approaches using memory reservation at =

boot time (such as hugetlbfs) are a compromise that would be nice to =

avoid. THPs, in general, seems to be a proper way to go because it is =

transparent to userspace and provides large pages, but it is not perfect =

yet. The community is still working on it since 1) THP size is limited =

by the page allocation system and 2) THP creation requires a lot of =

effort (e.g., memory compaction and page reclamation on the critical =

path of page allocations).




Possible solutions

----

1. I recently posted an RFC [1] about actively generating physically =

contiguous memory from in-use pages after page allocation. This RFC =

moves pages around and make them physically contiguous when possible. It =

is different from existing approaches, since it does not rely on page =

allocation. On the other hand, this approach is still affected by =

non-moveable pages scattered across the memory, which is highly related =

but orthogonal and one of whose possible solutions is proposed by Mel =

Gorman recently [2].




2. THPs could be a solution as it provide large pages. THP avoids memory =

reservation at boot time, but to meet the needs, i.e., a lot of large =

pages, of some of these high-throughput accelerators, we need to make it =

easier to produce large pages, namely increasing the successful rate of =

allocating THPs and decreasing the overheads of allocating them. Mel =

Gorman has posted a related patchset [3].


It is also possible to generate THPs in the background, either like what =

khugepaged does right now, or periodically perform memory compaction to =

lower whole memory fragmentation level, or having certain amount of THP =

pools for future use. But these solutions still face the same problem.




3. A more restricted but more reliable way might be using libhugetlbfs. =

It reserves memory, which is dedicated to large page allocations and =

hence requires less effort to obtain large pages. It also supports page =

sizes larger than 2MB, which further reduces address translation =

overheads. But AFAIK device drivers are not able to directly grab large =

pages from libhugetlbfs, which is something devices want.




4. Recently Matthew Wilcox mentioned his XArray is going to support =

arbitrary sized pages [4], which would help maintain physically =

contiguous ranges once created (aka my RFC). Once my RFC generates =

physically contiguous memory, XArrays would maintain the page size and =

prevent reclaim/compaction from breaking them. Getting arbitrary sized =

pages can still be beneficial to devices when larger than 2MB pages =

becomes very difficult to get.



Feel free to provide your comments.

Thanks.


[1] https://lore.kernel.org/lkml/20190215220856.29749-1-zi.yan@sent.com/

[2] =

https://lore.kernel.org/lkml/20181123114528.28802-1-mgorman@techsingulari=
ty.net/

[3] =

https://lore.kernel.org/lkml/20190118175136.31341-1-mgorman@techsingulari=
ty.net/

[4] =

https://lore.kernel.org/lkml/20190208042448.GB21860@bombadil.infradead.or=
g/



--
Best Regards,
Yan Zi

