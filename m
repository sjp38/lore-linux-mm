Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EEA8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:48:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E069820651
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 17:48:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="X98tPKAj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E069820651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FBAE6B0005; Wed, 27 Mar 2019 13:48:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA4D6B0006; Wed, 27 Mar 2019 13:48:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C0D86B0007; Wed, 27 Mar 2019 13:48:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 350DE6B0005
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:48:28 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b11so14630258pfo.15
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 10:48:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=3uC4woD28mUbj6hka+LT/3mMwTXJ9j6nWGLKp/z7ZUA=;
        b=HsETSIHn/otYvTIofIca+PS1unt9VB+kgwE4cArHlrgGnWeKUXgjU9dLTkHA6VT3dM
         dxhcOYK4jgbDlaawnAH4U+unDEULjaCE6AtGMAhjO/zfwMrXGTo7C4+7j/XGPWftOyNA
         Fzry8pmBhjtePS+3KjlL3J0FOXl4/ykPZx2EkAcFrRH4eVs2iTzitHFhH2OoV9KXQMWy
         pDaBh3rewUwjNcPVCpPoEU/ebSfvc8IIK24cJwacD/Mu6WqIyz7sJ0D1SDvmWT79pgSO
         Q3jXQDFkG24G45M4/Pq20vU0yrEX/qFiKC4Zb2Tyvz1Za1hRg9rv8fH9pxyfRiTnzFoL
         xfug==
X-Gm-Message-State: APjAAAUcxoV/9CqzH6V69Z1UZFNzLh5ej25wgQvNRPz1QSIs9JkWUz0t
	LzES4OEDtJb2WtaHuw74Y8d+Khf8fIf3274rpAxE8HcwV/DMgByN3mBysCsMZqAW+bmFkI2HAv8
	P2quAjOfVrFaG2Vrlp4EVpK/l/9hRrsn4Q444wvMyZAjtEScomGRlrGTy1Oo9BehzzA==
X-Received: by 2002:aa7:8c84:: with SMTP id p4mr23057631pfd.164.1553708907569;
        Wed, 27 Mar 2019 10:48:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkvn5RxKVoo+NXiUMbgNwFPUnY2aiJu/0RBLAlnHjA6/HCAZFwyHSg9swrYU6Vma6bwSyJ
X-Received: by 2002:aa7:8c84:: with SMTP id p4mr23057583pfd.164.1553708906804;
        Wed, 27 Mar 2019 10:48:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553708906; cv=none;
        d=google.com; s=arc-20160816;
        b=GOD+FqApdpVITx8vfLd4bPdwa4h62+Bm3MBjXEyVfh/AxJ572nAXJjM3LscNMy2mwz
         H8ZrVNO+0TpoJABPMDMzcjX1JjJZ3cKfXrxlZD+uUFJ2MfTBJ6ofWQIxb5p8TTZ/LOgI
         FwIDwbKzMh9EcuJ3eiVBIjfqiMNuhMGU3D8HIUoI2ZOQEQrZiESGQ9cK5vrGgbEJC4yl
         ThqGHXMsiqXSYj6yUJB88yWo8gOuor7j/Tx6t/ATcawFiVO0RPCVIRxD0SgFjcO0IggP
         vfTI8Zb0HJNWaFbp3KV+hT1UGsQ0tMjL2afmirnwnQwlvPZhvSzfLJBRwEn9k3Re9bK2
         qx6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=3uC4woD28mUbj6hka+LT/3mMwTXJ9j6nWGLKp/z7ZUA=;
        b=btFYHjyAOHmjQJXgIsexohPtF/L541ukFKuTUZ7Z18r/Kd28dx1iyigzDaqbccxgXk
         ejJvZgB96khKZHLseTkvnNp0Mx7dDfq5rsuCgfkw3MQ/Z5brsUAjv75nOTlKfa51mfaR
         4SbEzdJLF6IRoG5JmpGQWSh4Rg/ynfyBP/pSDVAK0qDpJ1qHRmC8/FAxcGKmP9Rxr77W
         Hb8aeD1i+l61VVpyDlGxnz5az85hR0hAiaduEpoRH9AYsVXbT9YUDVs40+p1guMtal6s
         SqQw3lsveYdS0NCx/j95K8sWc66gHPLQBmbljgo7OzXGbhuOHnHsd9kMx3tiZExDMXuO
         0Zug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=X98tPKAj;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d62si19482525pfg.209.2019.03.27.10.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 10:48:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=X98tPKAj;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9bb7640000>; Wed, 27 Mar 2019 10:48:20 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 27 Mar 2019 10:48:26 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 27 Mar 2019 10:48:26 -0700
Received: from [10.8.0.10] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 27 Mar
 2019 17:48:25 +0000
From: Zi Yan <ziy@nvidia.com>
To: Dave Hansen <dave.hansen@intel.com>
CC: Keith Busch <kbusch@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
	<mhocko@suse.com>, <mgorman@techsingularity.net>, <riel@surriel.com>,
	<hannes@cmpxchg.org>, <akpm@linux-foundation.org>, "Busch, Keith"
	<keith.busch@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Wu,
 Fengguang" <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>, "Huang,
 Ying" <ying.huang@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Date: Wed, 27 Mar 2019 10:48:24 -0700
X-Mailer: MailMate (1.12.4r5622)
Message-ID: <33FCCD53-4A4D-4115-9AC3-6C35A300169F@nvidia.com>
In-Reply-To: <de044f93-c4e8-8b8b-9372-e15ca74e7696@intel.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
 <2C32F713-2156-4B58-B5C1-789C1821EBB9@nvidia.com>
 <de044f93-c4e8-8b8b-9372-e15ca74e7696@intel.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_DA82EAD0-1665-4A6E-B1C4-471399DCFEE3_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553708900; bh=3uC4woD28mUbj6hka+LT/3mMwTXJ9j6nWGLKp/z7ZUA=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=X98tPKAj4hWpv3TDBg8/pHxYNSMGqMi0/QaE8gplerWMfZSBIc5ZnYiexlpuTHm0o
	 Gh8qlMZOGrJxuIQZ3EGawHq1OGSdGasO+R/gupi7qVvTIhjIl+p9dfY89xDP/sY+4c
	 xGVQs5HisiJNKQN5WonEb10vr7v7TAKurUWE/CMSjtrZh7cY69nvcxrOfqAXURsXbx
	 XZI0IzLMkN7sGzSybiFTccCD1qpfY2xYl0nHJ4vDv3GBYcg6ER3xLdFpKs8QeqkvaL
	 PllnVqu5PE39ToT7MgShFrCpP1u9SxCgny8QpPf7jWiUCpCG3+CFGnNK+v9nzfOV6M
	 ZoZToMd+wPGKA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_DA82EAD0-1665-4A6E-B1C4-471399DCFEE3_=
Content-Type: text/plain; markup=markdown

On 27 Mar 2019, at 10:05, Dave Hansen wrote:

> On 3/27/19 10:00 AM, Zi Yan wrote:
>> I ask this because I observe that migrating a list of pages can
>> achieve higher throughput compared to migrating individual page.
>> For example, migrating 512 4KB pages can achieve ~750MB/s
>> throughput, whereas migrating one 4KB page might only achieve
>> ~40MB/s throughput. The experiments were done on a two-socket
>> machine with two Xeon E5-2650 v3 @ 2.30GHz across the QPI link.
>
> What kind of migration?
>
> If you're talking about doing sys_migrate_pages() one page at a time,
> that's a world away from doing something inside of the kernel one page
> at a time.

For 40MB/s vs 750MB/s, they were using sys_migrate_pages(). Sorry about
the confusion there. As I measure only the migrate_pages() in the kernel,
the throughput becomes:
migrating 4KB page: 0.312GB/s vs migrating 512 4KB pages: 0.854GB/s.
They are still >2x difference.

Furthermore, if we only consider the migrate_page_copy() in mm/migrate.c,
which only calls copy_highpage() and migrate_page_states(), the throughput
becomes:
migrating 4KB page: 1.385GB/s vs migrating 512 4KB pages: 1.983GB/s.
The gap is smaller, but migrating 512 4KB pages still achieves 40% more
throughput.

Do these numbers make sense to you?

--
Best Regards,
Yan Zi

--=_MailMate_DA82EAD0-1665-4A6E-B1C4-471399DCFEE3_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlybt2gPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqK2AIQAIRQiK8keuvId46x28T0mxfxbYEnY9JeawL+
A3wFyX7orcvpKhU34luIwqi1cidMS64yzUj6QImSMvHTbUJS94BAXUFXE3iEhvTo
tJlB8OvVsB0y6rItgU0sNelNw0cjI5zl4/Z0950ljRGrFAB5eLSpadsXSkQRzF/n
dUrea31T/Lw7nK1DQY0Zd3U7hIPXdB3N9And5zIm9L3SEC7dgIULYgfm6x09Q7fr
9ylKEFlXne3RPaBXbGkfBnS7GkqlLzpLMRfzIFvV1aVqOVS75IR6hYg/Jli+X4UL
5svPHFnaxnTEE74fkEIKpVYiZDot3wc1UjGc/EQ7TTC5ZOOtp9bZROoEGQKgraAs
aRGB4yeLKac7LHD2sa0YI6mUtTl7mXscsSH1j7DM8LnX+svcZCk4lPpsW21DMYtA
s8lg13dBs2Y4oIV5MC85McxTfJj2w39c7kpgUxkZH49hJnZA94YSETS3SvdYZr2j
cT3uDMX6Kt/zQkWjcTZjiUp38ZNhg1NZtvrODf6SeVVXR+KSPxPp4rCd99MKDfT7
AiTlHYsE2dHa2JTp8CMZUw61RVpjjvy97C/uNiWTGquzKu69yvyD8ooCgeXtIi3b
AYCxDjlEITvVG+CSfZBwj4eDdeBRcar20dQNss1ZYxNy2bSFwiDOH7HLx/NqOg4y
0Cm+F72l
=Zvlc
-----END PGP SIGNATURE-----

--=_MailMate_DA82EAD0-1665-4A6E-B1C4-471399DCFEE3_=--

