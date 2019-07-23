Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E253FC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:30:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3019206DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:30:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dFlkIYFB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3019206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 470396B0003; Tue, 23 Jul 2019 19:30:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 421F36B0005; Tue, 23 Jul 2019 19:30:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30F938E0002; Tue, 23 Jul 2019 19:30:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 121766B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:30:22 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id p20so33997761yba.17
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:30:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=FDbwFDSZuMyIknDuhtiS91edYJrPm1xbqLmLfcav/Qw=;
        b=s30s3wUqolI9k+Ecp51lFqAAQksrmJpgBFDrTxK9HHabvn/TprTf287oVmbgOUltfC
         f63FrPyqbMhjDuGWN9lvpPhlBTlWdZrtrSSjpCuDvjj6jm5O8oM/s1pfEdxH+TYZdo4J
         fsQafOXs4PRDpsJpSux3+kNwdvpA98f8l2j9R5izUvcu9l09w3OZrEZcfQ4RQ7d/WfBh
         NRTGctDrejuf+ypEiwrH4EUu8DV3iNXAuA78UmE5Jn4H8utFL1JqGcaaX5Xlyig0ZDgD
         Jo9DPVVhF6WBhIttC8KzzWuiwxcb5Jai9z7+iJxQ5koXpbWY02xDLXGyuBiCen0OHv40
         Khsw==
X-Gm-Message-State: APjAAAV+WH0Vox9DWg3HLJqVvkTZbBV09ixHfFHpGv1XTg5KT4R2QwBc
	4TG+rgzChed5AfmcnMvykYlIXQrrv9+koLZ/p/rBLRamwKQGeVts/oVsxiPQlDnKtbDiz6pYid7
	BNSmt2nwLxbEmw6QkCcV6CxZfhjcwRFgQQhAcQSXlZ1yGX78pi5gGcd5LiHbsaIw5MQ==
X-Received: by 2002:a81:70c2:: with SMTP id l185mr45842639ywc.100.1563924621803;
        Tue, 23 Jul 2019 16:30:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmZ86RmLXm0A0J93vOCpUIEdXu+howeq9L7N8SmNtyrAdL6i+uwKSJglYOMF9R9TWBAs2r
X-Received: by 2002:a81:70c2:: with SMTP id l185mr45842607ywc.100.1563924621314;
        Tue, 23 Jul 2019 16:30:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563924621; cv=none;
        d=google.com; s=arc-20160816;
        b=Im0tP2RbIUqlgLm4aY31CdgvLiDO3Lz/GSQgRPuMb11TRvIGD5hFCvlqVVxPfJycAW
         fc0VRsIW61cAWO2arsQOsFwAMUatBtzsn9ksHgVpkVGpPZS8ZaFXStJsrD8UYm1SdEs5
         ofA9JCz6jqoYGE0LMJFFPb7WU7nXxhY+VflS17YtlTb/zTQK27UNi3aBgVoWdtNOp89N
         nSvQjlbocC2QsilHS9a5jIjzx7RWe7mBDwWYMw4HP3WLH+O2sTxUIuAHXo9GNGiGvhdz
         Lxgul9XChS1ijT7BzjodbwiL3u+tFuC0ZERhOR5dgGsslAdLNpqrxfXDFCUjdYKl1TrB
         rLRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=FDbwFDSZuMyIknDuhtiS91edYJrPm1xbqLmLfcav/Qw=;
        b=umRICuWiBAGvhPJWmvzPATdmfPVH62TfPPwpJHVBhx7+TBHChzYlu+NlKDv3a8I/Ky
         WIFwDIyzZnViviT/dC/4wT8ageQIWllOhXx6S+4KRdmc58FC5+rZdA9oUzT0jPxoYxgR
         uRKuv08d+BgZAfqoXe/pR2oGejxEsb9OmCOC9LsrOyK1UlXqFhTALXmdA1SkqCCYX6hM
         BQKAKssyAAYjrJ4KwQap8u0gS5EpjdnFoXQMzeUfPWgBSosiaGXoFoHzjtFaqtNx1Zvs
         UwSJhn8pI+kWvJwkwsMdw53LOAOYvbvRgddHIDmi98+wrN9w+C3rTg92dDRw7L6Ncuyq
         1dAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dFlkIYFB;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 64si15613844ybp.346.2019.07.23.16.30.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:30:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=dFlkIYFB;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d37988a0000>; Tue, 23 Jul 2019 16:30:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 23 Jul 2019 16:30:20 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 23 Jul 2019 16:30:20 -0700
Received: from HQMAIL109.nvidia.com (172.20.187.15) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 23 Jul
 2019 23:30:20 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL109.nvidia.com
 (172.20.187.15) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Tue, 23 Jul 2019 23:30:20 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d37988b000b>; Tue, 23 Jul 2019 16:30:19 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH 0/2] mm/hmm: more HMM clean up
Date: Tue, 23 Jul 2019 16:30:14 -0700
Message-ID: <20190723233016.26403-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563924618; bh=FDbwFDSZuMyIknDuhtiS91edYJrPm1xbqLmLfcav/Qw=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Type:
	 Content-Transfer-Encoding;
	b=dFlkIYFBEahjwsEE41Zja3tD83QFXyCZwYtuwUf3HBcIKWr/C8XVrbvjMIQm1+Lo0
	 Vj9TsJdpNOTAuaK1b1PgiMTlip9kDy1Hfro5q2mEpL2opgUnegJ+1Fm/F6MF2PATXh
	 Gd4P7ZaDfwpKawPOmovjf/1lrYBxgpvagSXMctDX0o22gStsuEe+M9kyU+x8hKXAqg
	 ZJ4W7J3TKLOk1fnttYAcYFo9E0VkpNcMBwcb3tYKJfDKaYa+xUks4qBrTaaHRcUxac
	 s1QP7P4RLQPRM52ylO0zWpcoLzP69Zz9JWkIk20IcPGb5KoSw3Lgd9zqvwWvb7mbg5
	 uywZaQAcOHSBQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000292, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Here are two more patches for things I found to clean up.
I assume this will go into Jason's tree since there will likely be
more HMM changes in this cycle.

Ralph Campbell (2):
  mm/hmm: a few more C style and comment clean ups
  mm/hmm: make full use of walk_page_range()

 mm/hmm.c | 231 +++++++++++++++++++++----------------------------------
 1 file changed, 86 insertions(+), 145 deletions(-)

--=20
2.20.1

