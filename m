Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEECBC31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:51:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 949E020848
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 08:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OiX6cA+H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 949E020848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 342248E0003; Mon, 17 Jun 2019 04:51:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CBAB8E0001; Mon, 17 Jun 2019 04:51:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16B4F8E0003; Mon, 17 Jun 2019 04:51:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E04F48E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:51:22 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so2516547pfi.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 01:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:from:to:cc:subject:date
         :message-id;
        bh=+s0hvx2ZoDdfV9Um7bwyvmqpYaZupeqRGDBP/P7uEqg=;
        b=SZ9j/xQiUoVzI2ewkC+XjsjhfKfpUYrWeouujd7TlMwqaHz12EpWHSneFgVix+fCtY
         6P7+3nIoKoRF/Gz/G2tGW4CKDk5oSvkwql4gFGj/eYC4SlHFTkBDUV/sETHgYoos09ZV
         X/uLilyM9kJrWTpCqzaLdcbwxCA18X4KFkqR7dS2bfZ4lvFBOgtDvTP3u3VNdaj+s8p4
         G13cUWXOWMro1k+kqB2dBpk/iRgZ7bGusF8PHfGdtyhNKDg48IqoPRn5Tbo231tpHxOs
         JT0D3YoPzfpKOaCi2LZC8y0UDInPmjZj42q8ab1AOLVe5GRKuvv0gErl3NluEGzi7ljs
         59mg==
X-Gm-Message-State: APjAAAXk7t2tFo7oM7yuJcBcNByhl8qHTZrLYjV5FHmN+1x5xyhVU0dO
	azN4mY/A1sSEwK3Oepj/FAMrVv1EgSz1iVdF3XyZiPgZsRdYLVpYF5QCGPuHHxhvLTNoAqFsMuh
	tN/k6hd/GrnSTw8AkspZhebS7/vGJl5nHTyvbXnS+q3EqBn54D7eBVcoINXJ9bLY=
X-Received: by 2002:a17:902:9a49:: with SMTP id x9mr86858526plv.282.1560761482523;
        Mon, 17 Jun 2019 01:51:22 -0700 (PDT)
X-Received: by 2002:a17:902:9a49:: with SMTP id x9mr86858490plv.282.1560761481886;
        Mon, 17 Jun 2019 01:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560761481; cv=none;
        d=google.com; s=arc-20160816;
        b=s4LT3ha0XjkjAvB4kTaMqT9XtathieSgpYocK1CglCVtqb5A9rZ8QwtltxgzedqTrp
         UwDDi/X/XHeVTwAkG/a8bqQTMzu2gJn7ioSqpLsJ6k0ODR6r23iefol31ifJlyNotcZD
         m7FSjzAhjx/ErVZHC4erflAV7oPDF8Rz8gF+nAvbWITfEagMOcPplCXaRbFlbQMQpV4S
         PfEUNa1W4X6JuFF8pZOb8JnaNgkz6SjVtM+4zVyFES8qKVArmCl+IS8hPHOKQ5ERNqH/
         LijBMfU+izDpMTnXCBbNSuSxRO1klQJdNttTIUwl8d6wKczwT+Ps6vPjdwZlOFxQS3kV
         fXmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:sender:dkim-signature;
        bh=+s0hvx2ZoDdfV9Um7bwyvmqpYaZupeqRGDBP/P7uEqg=;
        b=rn8Do32oOJzM3zLuJ0fqKsJxDB/DkukKw8YP/YSFBKwpaFzapk058FqHTqFwAC7RNS
         LO1mkHQpP88wQpcJa6u5n028Nh8ld7oJjxxvnuGuR3gyPi+d4Di/aMbutcCPBt8bQXAQ
         vvtvPgDjx+BjO4rCYcgMLnzQ98yfbaPg2PVr4PLkkuuoSlh9EFTcCurdRYQ1kjX3UOae
         aVL5s3DgScMfYz+BxhXjxS0yiBZb2yEHinixHfe8KAGbAk8NULUkPeXGQp3fZaZDMddh
         51wKu8J9sZFKTVCbQDRDMzrxhGHob3DocXGH3vVMyU+xnUTs+x0mDQH6XPkqjws2pzF4
         YvqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OiX6cA+H;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 21sor10234761pgl.77.2019.06.17.01.51.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 01:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OiX6cA+H;
       spf=pass (google.com: domain of nao.horiguchi@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nao.horiguchi@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id;
        bh=+s0hvx2ZoDdfV9Um7bwyvmqpYaZupeqRGDBP/P7uEqg=;
        b=OiX6cA+Hu3qeu3+KIo7CeyjC7JR3UwFUkyTATiVz4UmWKl6C63xQpHeWH979BnZHm+
         mgJ+4s1Y5Yv+X5c6unYaHlZ3j6sdioCOzftaai399R1q8HHmcrEZo5QzLFEDtbAZX9b1
         9bycHAoyiG6RVJu6IppS9DDiFTgEt1hl/t9KZupMtYkOD07aNyPIyocDd2QLhiAD0XiJ
         4E3TMx3k16+rsIFw2YbiTF7Yu17TxIXReLLjQvwEJIsSmnCv4IKyur8w1azrbgwbQ2ei
         pvkQJiWPDIVWoVSNO4gchOdVVxHKzzpBjc3jpJLgAvP56gAGE0GrXyA2FOhieGaUcdzE
         QEcA==
X-Google-Smtp-Source: APXvYqxAEo7y/HvMWEyG3WkPe8qZn830M+JpmLvFyOCawIbIq2ysBhAs2UlmtTxoi2lAcl1KpmvryQ==
X-Received: by 2002:a63:5d54:: with SMTP id o20mr45933531pgm.97.1560761481426;
        Mon, 17 Jun 2019 01:51:21 -0700 (PDT)
Received: from www9186uo.sakura.ne.jp (www9186uo.sakura.ne.jp. [153.121.56.200])
        by smtp.gmail.com with ESMTPSA id d4sm9443514pju.19.2019.06.17.01.51.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 01:51:20 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	xishi.qiuxishi@alibaba-inc.com,
	"Chen, Jerry T" <jerry.t.chen@intel.com>,
	"Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
	linux-kernel@vger.kernel.org,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v3 0/2] fix return value issue of soft offlining hugepages
Date: Mon, 17 Jun 2019 17:51:14 +0900
Message-Id: <1560761476-4651-1-git-send-email-n-horiguchi@ah.jp.nec.com>
X-Mailer: git-send-email 2.7.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi everyone,

This is v3 of the fix of return value issue of hugepage soft-offlining
(v2: https://lkml.org/lkml/2019/6/10/156).
Straightforwardly applied feedbacks on v2.

Thanks,
Naoya Horiguchi

