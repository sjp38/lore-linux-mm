Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD1FC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29B442086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:53:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29B442086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2AA46B0006; Tue, 25 Jun 2019 03:53:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE0D8E0002; Tue, 25 Jun 2019 03:53:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD7846B0006; Tue, 25 Jun 2019 03:53:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 63E7D6B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:53:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so24377253edc.17
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:53:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=GtFb1x2oQ1s4oVLLn37PNjVvlDaCyD0zWDCvyli2BTc=;
        b=pkwbKGByvP1cy514Ich9R6cGAByUC3FlpygcteXyY89QUtG8ZOAE8OmFbDL1yNZ2pa
         5tzmHo5qs7p6yUfMDvxAXj8YtbtBEhqJtIE09BblpD1nK8WsIP5g1/5Yi05qyWkrF9X3
         i4cbXkPRcDedYh604VKtmq+waaTKNIoHNjHMDsBobcyeIDCaDSS/UVh8kWCLWCepO+rj
         Pjcuy6vy+O1hfCYX7r4CoGNvz0bvnvpEgKx4PsR93tt3IKjRglfzdvcvxhTVfKpcxsZg
         WQK9HV7pvG+jOga3nuoLOTKpZ6YCzp5/sioTEqkEMJpjv7pWSnnMmWIpOAenocUXWeb8
         QTtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWpJ0D5BZSvKlkpQtXChiNOmB036iVMcdOHyXNRL5qRAClG1DQ2
	l9BTL2/7TGLyVt74NAa98Kdd5gBiqSu3eYb0odIgvpgrC/7szCpuzOjBfDszlPheTuArtQPTZbC
	nYjjU4RK4vytiFdUWHwUq/7ocaiZmdnGC4mkDXFMY8m6ftnhDILOpNDeNiZ6yHKH9YQ==
X-Received: by 2002:a17:906:f43:: with SMTP id h3mr16881040ejj.143.1561449186939;
        Tue, 25 Jun 2019 00:53:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4Jp0WSTiCiywdHOT2CRVrUKOyD19ewI3AElOkzSmhZcWOnglNKYdfK2vauAezEG4rTrzR
X-Received: by 2002:a17:906:f43:: with SMTP id h3mr16880990ejj.143.1561449186095;
        Tue, 25 Jun 2019 00:53:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561449186; cv=none;
        d=google.com; s=arc-20160816;
        b=bxJTzoidZiCcC3sxfd5hoagJnGzIhPrMo0ZvUbeG2FDxIca82qr/QVupiMmJQJRhwk
         TExIifI5NRH5kjhQPJNGmeZk1Cezx41jnA57PF6PQiSzR8Y6Ft45WLlZKqMtIENAl21S
         KQtO0p08+8PvkYpDz4Tvb+DbTmqUVoDseaQuOKmr6SH69NG8+KitV0cY36DPGsZay+BP
         H5xkJYSdUfv1yBknzrKXf6weIivjRMyW19IrzRaAlU3LVaWlMkWtQXXRFN1WFWHN/gAo
         hfC0xRY+3eC+MOFwQIBDixzrQqdA6Focf1dsLwLQnlYAQF9on+HwNJk4n5oPE0RI/w7h
         id5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=GtFb1x2oQ1s4oVLLn37PNjVvlDaCyD0zWDCvyli2BTc=;
        b=u9hjlRjGXG7Dm3UqbTxGaPZAqqGYD+jrpNySZOggbCG0S65EiF5YHqyRYcXYSIRiTj
         VIpnk+6DUPOFcNj5pEMRbV+XQloxC8oZ9Wwo0dRtL+c2nzkXjTSLkhbxzgOAOFsajzWS
         HkCceQZfRuPYeVZ3WS2VFYBDj5fb5D4t507q/+DToh37ZXz3sIhbfUPGk1sqH0AljEdU
         2XR8cga+2NpcRKys1mZaHcZUZ8tja+9YFbzvxttoI8wf885hj3uZO+vl9JW0mYVXsaoj
         3Kue75Uzmzr36ouro+hdQtmcUl61JwhbkxaNLBtZc+/XrNAWRsteW+gkYW1cux2QdvNu
         H01g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id j15si12601282eda.119.2019.06.25.00.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:53:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 25 Jun 2019 09:53:05 +0200
Received: from suse.de (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Tue, 25 Jun 2019 08:52:33 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	dan.j.williams@intel.com,
	pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com,
	david@redhat.com,
	anshuman.khandual@arm.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v2 1/5] drivers/base/memory: Remove unneeded check in remove_memory_block_devices
Date: Tue, 25 Jun 2019 09:52:23 +0200
Message-Id: <20190625075227.15193-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190625075227.15193-1-osalvador@suse.de>
References: <20190625075227.15193-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

remove_memory_block_devices() checks for the range to be aligned
to memory_block_size_bytes, which is our current memory block size,
and WARNs_ON and bails out if it is not.

This is the right to do, but we do already do that in try_remove_memory(),
where remove_memory_block_devices() gets called from, and we even are
more strict in try_remove_memory, since we directly BUG_ON in case the range
is not properly aligned.

Since remove_memory_block_devices() is only called from try_remove_memory(),
we can safely drop the check here.

To be honest, I am not sure if we should kill the system in case we cannot
remove memory.
I tend to think that WARN_ON and return and error is better.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/memory.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 826dd76f662e..07ba731beb42 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -771,10 +771,6 @@ void remove_memory_block_devices(unsigned long start, unsigned long size)
 	struct memory_block *mem;
 	int block_id;
 
-	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
-			 !IS_ALIGNED(size, memory_block_size_bytes())))
-		return;
-
 	mutex_lock(&mem_sysfs_mutex);
 	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
 		mem = find_memory_block_by_id(block_id, NULL);
-- 
2.12.3

