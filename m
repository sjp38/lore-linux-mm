Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C187C282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:26:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEF7A2175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:26:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KJBdvbCR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEF7A2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 602DE8E0007; Mon, 28 Jan 2019 11:26:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58C118E0001; Mon, 28 Jan 2019 11:26:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 456148E0007; Mon, 28 Jan 2019 11:26:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0D488E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:26:09 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so14460442pff.5
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:26:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AFkCwrE3u3Go3QXeezohib+sLwadB2sFKO3REWY0nhk=;
        b=B9kIjR5Dg0cDM5uVKGRhc5B31e6icuhAczyQTOzhmh+2MiomqKcKE2MmIp2D+tm7h/
         ajnc3/QVKlAyhiQBAdOW5Le9byyAigFBzD18/75hf+TzJ5AvyIKLMcPYKIz1rfLuu87x
         UsPD7fJBDpIrzqWGNS0/qO9hTbY/I4H9NBSACqf03slukrhIIgUyA/mzlmnj6clf7njq
         0cuWRbJi4XK+7XckuLp17k+NYHcQ8xEpuFN3qRcAgZaSW9KyyKhO1haAQGDTk8prLh3i
         VPVYAGWtvRx8fg/WptkD+fdeX4foqDyumT1EnSbNGg1vv2TMEDAwlR9fhAAoftcCW/jb
         +nKA==
X-Gm-Message-State: AJcUukeVBz5rNd0d+RAXg431JSvD0hXnY4v795UdtuI2gCdzoOV8s9js
	gvxVoTNvFp5t9z3Lasnxh3I1vrshopBthn3b/4KOAJnIz4SgPwuWPGepqV2aJ0EZw3YW2WpwVvn
	TIsTWKrBfFQptfVjCneSjv1dsaqUVzqD5lmv5djgiM2A5bN8iM5dujkGa4CNBIdcRgQ==
X-Received: by 2002:a63:f109:: with SMTP id f9mr20219076pgi.286.1548692769606;
        Mon, 28 Jan 2019 08:26:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4n7QYkUQ/Gkxi+rLIufaSdPMEV5T5wfrRKyoN1PAj9Bhx28rOpS91DGyBOQIUiYcFYz0yJ
X-Received: by 2002:a63:f109:: with SMTP id f9mr20219054pgi.286.1548692769087;
        Mon, 28 Jan 2019 08:26:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548692769; cv=none;
        d=google.com; s=arc-20160816;
        b=Bn4OVHvuphAyOf0Xv1DDD1v5X9G5xyimBQ+0lzKUzK4DLAEs91IYRihhxdSars9wFR
         oM/CYec+ErDGgk9AIra5MPY9JQ11JZcZQ0jTXrSHSMUBT3Nh/RetFASBh1L9MVlhATHR
         Nq0a4qYlJL5QR3dx6RbGGigC1zxOTINlsCEA5chxGIHtx8jxumPu10nXdHwyQhRgIMIR
         A+tWiQHXD8ioi2zLoYcedGhEUTa51aqITog8hGvJcL8EawNplc8bDROdxsYtGvm1BNuZ
         Tvn79oc4my5dbOVoYJ9czLMKFGaSv0cWqxVOgl0H4DzmZv+q/rbRa2Ml3nXUXi/zq2io
         Xrow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AFkCwrE3u3Go3QXeezohib+sLwadB2sFKO3REWY0nhk=;
        b=Rt7ElfIc2yFW8EJ8ED7dJ3qg5FICdEo1iN156mudeIgfg+dEENvjTLv5OhlBn+fLy5
         ArnUseK+ygx6yj41IHDIT8DVABqICLdN8wh0POMCRnrZErDd52qG/5Ss2cdwqP7w0EA6
         9rYvO20fcsR2amy/nHPH05+WRKBaAHNJ1NVERC2AO+jxSU3OmkyM47eCCDsAX69jHoDo
         MZ8AdatFV1zdx86a4FzpTqaUk1kJ50DsjvVuX/FvlBTQ/cF3Dod7opJGi1Rg2XzVPNeo
         Iba5B+Suyey4Z818NcDdGzl7KLSvZVkp+b7L6u3DqDq8tSd29vfpoOmtawRGkstmK3Kl
         u5dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KJBdvbCR;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v83si32927290pfk.264.2019.01.28.08.26.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:26:09 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KJBdvbCR;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BDE152171F;
	Mon, 28 Jan 2019 16:26:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548692768;
	bh=wcKouzECdD6zHg5fTlK0U9Q/4g/hq/VirLNmAMCDGZk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=KJBdvbCRVwtMT8bUfJP9U9wXd3JecD9sL3K2lIg2vmtPheZFzuCEus9OidZ3eiN8B
	 baXQvwzN9x0SHJUadBBe4XtV9YbwlNeYyDxHz5vfA/EwyJ7/JyoF5YDbi8289sfWzO
	 ApDRyOP64/2mUHP8+h0FzWzKTDzNJI3PLzOyOfaY=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Miles Chen <miles.chen@mediatek.com>,
	Joe Perches <joe@perches.com>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.4 72/80] mm/page_owner: clamp read count to PAGE_SIZE
Date: Mon, 28 Jan 2019 11:23:53 -0500
Message-Id: <20190128162401.58841-72-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128162401.58841-1-sashal@kernel.org>
References: <20190128162401.58841-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128162353.NNol1kQTbOydftFLJA9V05XDbX7Wj0pQg71TYAXhXHQ@z>

From: Miles Chen <miles.chen@mediatek.com>

[ Upstream commit c8f61cfc871fadfb73ad3eacd64fda457279e911 ]

The (root-only) page owner read might allocate a large size of memory with
a large read count.  Allocation fails can easily occur when doing high
order allocations.

Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
and avoid allocation fails due to high order allocation.

[akpm@linux-foundation.org: use min_t()]
Link: http://lkml.kernel.org/r/1541091607-27402-1-git-send-email-miles.chen@mediatek.com
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_owner.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index dd6b9cebf981..9c9f32fa70fa 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -107,6 +107,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.entries = &page_ext->trace_entries[0],
 	};
 
+	count = min_t(size_t, count, PAGE_SIZE);
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
-- 
2.19.1

