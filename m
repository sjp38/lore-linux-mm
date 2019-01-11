Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF4DCC43444
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9BE2084C
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 00:26:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="NWvzfKHn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9BE2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48E638E0003; Thu, 10 Jan 2019 19:26:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43D4B8E0001; Thu, 10 Jan 2019 19:26:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 354808E0003; Thu, 10 Jan 2019 19:26:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E974B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 19:26:42 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i3so9019798pfj.4
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:26:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version;
        bh=6VLDW5TH7W0fiA3LQLDP3Qgvgu7yECgoZDOg7pFZzkk=;
        b=WPto03TsjXF1b+IaUz4Pv7b3YFzl/W/MqaEldmajbwAVf+EMKJq9296aY196LN/OZh
         9fklzREozJZfC/rW0b+SKQzEcMKFyLn2SQvSuT1Rh0DFMHxsXPd5WaK/SrJb/DLgGO3M
         M1Gq7A20p/sMmuvm+8L8ZhPfdhMRFXJdRyUZqTVnk/GtdE5913HXthZspDnM7NO3XrgQ
         CuAeFVnWpd5TIHcJ8HxmuFrN7YiIFTiq0R7aZzifC27X0EJhHKzrB8feUGFp4o3U4m0w
         ieGkh4EFCNc0kweJIHe/SLxxBMcIizJ6W3zQYr0wMPeCYzzsXZ/M9nWWVA4zO2ABiCal
         wjKQ==
X-Gm-Message-State: AJcUukf0jcshNwjajQUllNeIWZPxIzgjpxGuz1NUeKFkZyecTBl0/Goy
	WkV/Pkj+JPNgCKDbirMmcase5zzt+rxYIGAye3/RIKKW/BDfFb8HBLoom1EbBS274OuE5bO/64N
	txqUqSjL1SkICQLr5AcIgtOzdghYS8qgWXgWNyP3YTgp2/kvwjmmFANr+BShD30aEiQ==
X-Received: by 2002:a17:902:830a:: with SMTP id bd10mr12490958plb.321.1547166402570;
        Thu, 10 Jan 2019 16:26:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6tKXvgU6gir2RRcYDnBvxw++/pCLio/nkUkxLsF0VbMihByB9yvZWL+I313ean+p7xBQB7
X-Received: by 2002:a17:902:830a:: with SMTP id bd10mr12490921plb.321.1547166401817;
        Thu, 10 Jan 2019 16:26:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547166401; cv=none;
        d=google.com; s=arc-20160816;
        b=ooPWxia8xOGodJnIe03mcYgIJDClqx60PrW14ys95GolGKx2Q7B66u9I45E5s1gHrv
         Y8AFS9McR2ZMHMv7X1iD0kewupm5PcnnmZoP0rZwR3UDlpr36bV8yVSBTapHfzT5zVnF
         47JK0Q2tW3CI0trrKTMUI6r5RC567NQhb35LbxERlhEcVis7v/moIm6aCMb5P9A4EthS
         px1eA5ljWYgjLV3sHOrczq4C1wyF4+fC1LjtAeRuI/IlHxS0JyVkEtJUSL6fYFkkPEie
         5kGyCOm2+3g+k8fnnLO0TXRJNOXJG0UtUBu0QEgZ7ozQDJzaVa62cveciD1DrV+n7qg+
         kstw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from:dkim-signature;
        bh=6VLDW5TH7W0fiA3LQLDP3Qgvgu7yECgoZDOg7pFZzkk=;
        b=RBGw+rrGkWKxzD5OvQRc03ygxqih0CquUYwsxeWMtaf3wlOPZHAqyE8OI+fE9VPe6Z
         M8ano0TQnCAO8YkyosHxKEu1QcyIngeXhdW7iBuYO4BxWW937TudREwExRSTDKl3ozSx
         gf/pW910BakvhT0f70wruPuVudIR8fpfXLOgYWhvTuaooyp4AqH9bQFBT7gsUNG87fRd
         xRY50UZCB1quq1YQv5HdJdPNZ4sQkhrQtKtk4cZ5abVGc/+FgQKOgjxrgzMWY/33fA/a
         EzbnXuqnfRGJFSz5OPda5046z6b1uZf8HSJX0E3qOXGpP4wECNqCEGTvyMQw83wZg2V8
         busg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=NWvzfKHn;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id q127si5811602pfq.19.2019.01.10.16.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 16:26:41 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) client-ip=198.182.60.111;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=NWvzfKHn;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.60.111 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (mailhost2.synopsys.com [10.13.184.66])
	by smtprelay.synopsys.com (Postfix) with ESMTP id 2B5A610C06EF;
	Thu, 10 Jan 2019 16:26:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1547166401; bh=KGZ9OeLmlgo9sWjwCllJ2JfHatcqtBn7FO/ruNLVtd4=;
	h=From:To:CC:Subject:Date:From;
	b=NWvzfKHn4SzWSknpom+EaJ5nNKhfSjQWlUeCLMYRvImFBJlX3lVnn0EBHW1zy9m9l
	 zJBh2DKWqssQWl1c/17HGNlQ2l4p2zYOTBXL90Lfbh8Xq335xYPEA8cKyIlBZcjYw4
	 7QQ5qsci411q9R2mUrVC8ePZdOz5JR2nfHRSXZ5N1j+UcJDqJb65t1u7OzsKGGJ/23
	 8O3Jn7IvrZcswpdoe9YfVR+YstVVTwpeLHbFufr9o4JU57tTBbQ2fbSaZ8oPAyvpoG
	 qCTiOCewVXluJDWQtCzGlcwGZEl3F/l3/gsNC0Ng0I0aMPG6scawDPh2GCiAnoLWwC
	 p4PtqiZgmdacw==
Received: from US01WEHTC3.internal.synopsys.com (us01wehtc3.internal.synopsys.com [10.15.84.232])
	by mailhost.synopsys.com (Postfix) with ESMTP id 192A43993;
	Thu, 10 Jan 2019 16:26:41 -0800 (PST)
Received: from IN01WEHTCA.internal.synopsys.com (10.144.199.104) by
 US01WEHTC3.internal.synopsys.com (10.15.84.232) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Thu, 10 Jan 2019 16:26:40 -0800
Received: from IN01WEHTCB.internal.synopsys.com (10.144.199.105) by
 IN01WEHTCA.internal.synopsys.com (10.144.199.103) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:39 +0530
Received: from vineetg-Latitude-E7450.internal.synopsys.com (10.10.161.70) by
 IN01WEHTCB.internal.synopsys.com (10.144.199.243) with Microsoft SMTP Server
 (TLS) id 14.3.408.0; Fri, 11 Jan 2019 05:56:40 +0530
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: <linux-kernel@vger.kernel.org>
CC: <linux-snps-arc@lists.infradead.org>, <linux-mm@kvack.org>,
	<peterz@infradead.org>, Vineet Gupta <vineet.gupta1@synopsys.com>
Subject: [PATCH 0/3] Replace opencoded set_mask_bits
Date: Thu, 10 Jan 2019 16:26:24 -0800
Message-ID: <1547166387-19785-1-git-send-email-vgupta@synopsys.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Originating-IP: [10.10.161.70]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111002624.LTvzGWNpklB-IRI_UzYsmWBD6qsJeBs5F5CU5Lwy2Xg@z>

Hi,

I did these a while back and forget. Rebased to 5.0-rc1.
Please consider applying.

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

