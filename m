Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28264C282C5
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:35:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB1F52184C
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:35:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="JWrxhFw7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB1F52184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 729938E0048; Wed, 23 Jan 2019 15:35:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FE7C8E0047; Wed, 23 Jan 2019 15:35:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57B928E0048; Wed, 23 Jan 2019 15:35:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 132CD8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:35:14 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so2631353pfr.6
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:35:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version;
        bh=fUWu/5Gpd1V5jQJjENWZ3JbzaZ2g/gI5Q7hZE6GBGH0=;
        b=KeFs7nvV4a6EfutcgAzytrNUOkdJoaDBHhXgyejDGnxd7dUtSRlnbma424xKo6j4HF
         04ysNirUx6fzr+E3v23lSk5h6n87MRMB0KOWbqfxBpkTKIwhQT504EOfMO1dnR28/+Xb
         SZ99ecgQfPzB5iFJzw52V3M8730k1P4j69JE4ow4+csq/oN9CpyN0PF1wwT9OWh3H7og
         h+1Zg8hMwkdbWx9Ky0AXlRxGyJSlP5EWXnEUG0NAd/EXHZ1xvliOABfhYmB51ANYqWa9
         kSjFFavUQBhDPQRKlSVL2k4XojFXHmJPWeFqVuLiTMRLsuh+iTSeHAPqzG2bAL7PcR9p
         KaRA==
X-Gm-Message-State: AJcUukdC9qB8QdwsUtRvCS3VVTIiWIO+9OyOf9Di5dmOcA8eVACBznJU
	000I8KxfUJYyANG0OD3r0z0aX73jPkaVesGaX4WGu7AvsMjGjv/jglbXbzYpAxH8CooNyajqglT
	TW2Ls/aPThR+umQ2HXijz+lQSp1f8HnFQlt69wa4Bjeug72XAAlKRgx171Gtviw17pw==
X-Received: by 2002:a17:902:d01:: with SMTP id 1mr3800701plu.127.1548275713757;
        Wed, 23 Jan 2019 12:35:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7bhsldXLjA3s5wod9QiA/TSFstGKytkWWew/eET62rwZQeWLb00eIgAwRHz4WJkY2ORKfX
X-Received: by 2002:a17:902:d01:: with SMTP id 1mr3800672plu.127.1548275713201;
        Wed, 23 Jan 2019 12:35:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548275713; cv=none;
        d=google.com; s=arc-20160816;
        b=yGfwIQkWZXpPvtlwvK7Rk9EVeSKp/oOa/QGeEiYLL0OyEQqOmGYMqeqZQiUKdRwxID
         oXYhgINkbG1SgPBBWuXwJK02bgk9k+HLgNIMCikL6/9Dzz8hqXesJLyP9Dq0jn0aRNLf
         W0fVpYuIx6kfGzWc+GX6JCJUkmi4JYaaPJfI3NSbf06p65CmLcLyQckqNVnHTR2PqmHI
         JaBPUwBt5zb8KdP/pcNq9eQ2Nk7uOwBsjtkuUZmNTB7IfYszDfzhpEx6Ku01pZdI/iu4
         97hcvSphG7mgVc1sIvqdM2Lu1GaoTwgapnCz0Xc+Rqt1huSvB+eACisnY1gDcyMbRwp8
         HgEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from:dkim-signature;
        bh=fUWu/5Gpd1V5jQJjENWZ3JbzaZ2g/gI5Q7hZE6GBGH0=;
        b=VuoZZT2TXWT08dZXyZhaCnyiBvumZgLUg/b8H1noA2J3nUXSvA74a01EkKxkyzakkW
         WnHCc3xziV+KAf7Ixo/45zIHHJR+8CuyFWTR36Z9JyB7vvnMHdv7E82AxBAoVNH8+vg1
         RujEzlpS7NBp93npgVA4BZvx196ZDf0O9LeCjBvGt047hoHZqJfdoVAAGjwp/00D+OZI
         9pQYf7il/Q5mLsRObj1+TwNxBBTMwyeQPF2KKUEwt486vSs+/7mXv58yfbbRq3oxge/s
         r/7CSin7qPPlxPyr4zNddWsJ864zHl78Lz4g5dhiUnioj1TuwesK5TFoCfwnqVU9JTWq
         fftg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=JWrxhFw7;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id u129si18867621pfu.117.2019.01.23.12.35.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:35:13 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=JWrxhFw7;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc2-mailhost2.synopsys.com [10.12.135.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 958A324E08E7;
	Wed, 23 Jan 2019 12:35:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1548275712; bh=g4XgkA4cBcQ2d9YDPsJLRxz08eNMX3SB4ubYnr6xZwQ=;
	h=From:To:CC:Subject:Date:From;
	b=JWrxhFw7IUSZ4Gx2GxVT5KLRUnzRif3GvaEXl0SkaREiyYijNemZ6vn6OyQCbtLj7
	 b3WyfnA9gDoaJhUtwXHZ+JHIr1gd65ed23Bx39KPtFhoeUutQe+qPAk+fl/edDsTbe
	 h/CI7T7/uuqXtbfq2xgMBczPUPWodjP7vRpS15A5l/rLgRV4oLdYRHRRJ1XY48XJvk
	 CWhnqD30Yd0NeQphMCP7THMIhhM9PW0GAT7eHcPAD3S7FOqmNwqFEKpt4myVbW6aRV
	 ajb30pwaaX3Sfy02URS3a1bGxFdBUL0LYnAEOHtuz2+aGGI8X9Ki2NVe8SnieZRPoh
	 nIzLIm00VO5XQ==
Received: from US01WEHTC2.internal.synopsys.com (us01wehtc2.internal.synopsys.com [10.12.239.237])
	(using TLSv1.2 with cipher AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id EFFBBA0093;
	Wed, 23 Jan 2019 20:35:11 +0000 (UTC)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC2.internal.synopsys.com (10.12.239.237) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Wed, 23 Jan 2019 12:33:17 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:18 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 24 Jan 2019 02:03:15 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, <mark.rutland@arm.com>,
	Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH v2 0/3] Replace opencoded set_mask_bits
Date: Wed, 23 Jan 2019 12:33:01 -0800
Message-ID: <1548275584-18096-1-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123203301.nAF2zyYEzcDwc_wuKvMFv_e91Oyto7aClm8EiMF-IQw@z>

Hi,

Repost of [1] rebased on 5.0-rc3 + accumulated Acked-by/Reviewed-by.
No code changes since v1.

Please consider applying.

[1] http://lists.infradead.org/pipermail/linux-snps-arc/2019-January/005201.html

Thx,
-Vineet

Vineet Gupta (3):
  coredump: Replace opencoded set_mask_bits()
  fs: inode_set_flags() replace opencoded set_mask_bits()
  bitops.h: set_mask_bits() to return old value

 fs/exec.c              | 7 +------
 fs/inode.c             | 8 +-------
 include/linux/bitops.h | 2 +-
 3 files changed, 3 insertions(+), 14 deletions(-)

-- 
2.7.4

