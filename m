Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B068CC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 12:44:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 570EC208C2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 12:44:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="CZL/I2MF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 570EC208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9B4D6B0003; Mon, 12 Aug 2019 08:44:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A25446B0005; Mon, 12 Aug 2019 08:44:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ECEC6B0006; Mon, 12 Aug 2019 08:44:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0171.hostedemail.com [216.40.44.171])
	by kanga.kvack.org (Postfix) with ESMTP id 66FE76B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 08:44:41 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1564F180AD7C1
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:44:41 +0000 (UTC)
X-FDA: 75813744762.18.stage01_801ea164b1553
X-HE-Tag: stage01_801ea164b1553
X-Filterd-Recvd-Size: 4174
Received: from mail-lj1-f193.google.com (mail-lj1-f193.google.com [209.85.208.193])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:44:40 +0000 (UTC)
Received: by mail-lj1-f193.google.com with SMTP id z17so9711024ljz.0
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 05:44:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=CzrTbiHopzrJu+YLYHoIsujt53sT7XN4YE3jA26/XGg=;
        b=CZL/I2MFhnHG7WsGfil0Lhj0/vUbG22b1Ey4JJ+4mOZyN1TTt0k7l4o5BUszI4UGSt
         1n6tFYW9r96cIcKCqEuEC/X0AeIYX4H3btbse/XxA6HbmKV6iGxNC4/567RVUaDZR3nC
         HaBGbThoAuqSmKQ7S0HRYvg4C1CynhZlxF5TTej5/B6iJps7QKNTM4USoP9kAw899Z8y
         njUfwG3frFnuvYBLJG70NZ9gAM/sazFT3OtdhJd6YwKSg4tw6mibwBU/2nf6qJlB+PYs
         nEdfm2RkSbLQDJX7Q+RXVjY0XgH2jzOz2zIp+b1IMwxFfO6/cYmvcAAZd1PeK0vVqpsO
         voQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=CzrTbiHopzrJu+YLYHoIsujt53sT7XN4YE3jA26/XGg=;
        b=g19BOJEMRmIqqh8NY6kFx8rS3GNHyJqZcunrClLY0KT4I/wBgcHgu+MN49Z3H1z+dm
         vOz5vZrs/biAxFSw+HKgc47NWTni8/pdBP5YbhlEpfGu42KGgW9ZE7mpG9YLUyGzIXsM
         xBmx8+GvwfX1Q15PWMoxaOahYxYhgjBZwzI9BZh/wsWfCVvsm6pIyYDqjEQuMTzwYKBB
         M3Vu00BjwOrUjrfwf0EfrMjzOkLcEAvyZBMqv4PRR6yFCS9DuuQCqj9vP4HxGYMzDYVn
         43bHMXOThKYex85Y68EpdqPdZik+cosauq+b4A39bZIRSDsaxj4n4WRhlJLt5W+BMgyz
         PUmA==
X-Gm-Message-State: APjAAAUU2EFJ+BFxwvZyXppzxJygnkRhyVrg0TkrHqQdQ+T73WU802Em
	I3ToXWB65AKf2MVEFvxNwispyQ==
X-Google-Smtp-Source: APXvYqwamKoAxWVn0ZtiV6XAfXemkV1C3L3E5zzwIiIeJc4CgQilmql9PxxJQosy2E9Ep5TEcoG4/g==
X-Received: by 2002:a2e:1459:: with SMTP id 25mr18650455lju.153.1565613878719;
        Mon, 12 Aug 2019 05:44:38 -0700 (PDT)
Received: from localhost.localdomain (168-200-94-178.pool.ukrtel.net. [178.94.200.168])
        by smtp.gmail.com with ESMTPSA id y25sm23432747lja.45.2019.08.12.05.44.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 05:44:38 -0700 (PDT)
From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: bjorn.topel@intel.com,
	linux-mm@kvack.org
Cc: xdp-newbies@vger.kernel.org,
	netdev@vger.kernel.org,
	bpf@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	ast@kernel.org,
	magnus.karlsson@intel.com,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 bpf-next] mm: mmap: increase sockets maximum memory size pgoff for 32bits
Date: Mon, 12 Aug 2019 15:43:26 +0300
Message-Id: <20190812124326.32146-1-ivan.khoronzhuk@linaro.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190812113429.2488-1-ivan.khoronzhuk@linaro.org>
References: <20190812113429.2488-1-ivan.khoronzhuk@linaro.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The AF_XDP sockets umem mapping interface uses XDP_UMEM_PGOFF_FILL_RING
and XDP_UMEM_PGOFF_COMPLETION_RING offsets. The offsets seems like are
established already and are part of configuration interface.

But for 32-bit systems, while AF_XDP socket configuration, the values
are to large to pass maximum allowed file size verification.
The offsets can be tuned ofc, but instead of changing existent
interface - extend max allowed file size for sockets.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on bpf-next/master

v2..v1:
	removed not necessarily #ifdev as ULL and UL for 64 has same size

 mm/mmap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..578f52812361 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1358,6 +1358,9 @@ static inline u64 file_mmap_size_max(struct file *file, struct inode *inode)
 	if (S_ISBLK(inode->i_mode))
 		return MAX_LFS_FILESIZE;
 
+	if (S_ISSOCK(inode->i_mode))
+		return MAX_LFS_FILESIZE;
+
 	/* Special "we do even unsigned file positions" case */
 	if (file->f_mode & FMODE_UNSIGNED_OFFSET)
 		return 0;
-- 
2.17.1


