Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18B58C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 06:34:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A472C2070D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 06:34:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vexrQKj7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A472C2070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 109C88E00BC; Mon, 11 Feb 2019 01:34:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B8ED8E00B4; Mon, 11 Feb 2019 01:34:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10038E00BC; Mon, 11 Feb 2019 01:34:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5B88E00B4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 01:34:21 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id t21so5632920wmt.3
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 22:34:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:from:subject:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=yxRrm7VICj3zaCZA5XwcFN8ealtHYWBMkDEcG+Ng+Sw=;
        b=AR7SoaKwKE485A81R+lDqk0S86S7nr5jbskO1aeISvJuzTQ9ACbfWb1J0zV/0+iVqK
         QOrIXqf4PjtW11oJFGVdKgOR28LuAbFzmWakLvBfCM4ZtHi756pxikGuNnwF5pblD0py
         R/BTwfAcppop/H5u8Zs2AhrAoQecNDosvSQtXzhpD96B9JQW+9CxAa6d8B9M8sKdsQn6
         Ow9PLMQ1+ewzBVhqkwfHVGRDV4l9zdnIxGw1uWBGCk1PI/P/akBtBLbYbBPfQU8bCSpF
         MCbUt5nVJKlP4sH2Pgn1w4na7TG3XgL+j6YSH9bIcf3l/hvfFGV1l7QiS73PB5JPhQDy
         Ntkw==
X-Gm-Message-State: AHQUAuZv/FGwN79C5hDUDSnPOyWscYRAgptPT5FZE3JGpdVfa2soU+gf
	MP6TkGrgYQ6CthZXIrgV5Jd4pnGeyniNh4tLqf3zVjycsfHsD2fZByH1JaqGoUX7qtc6dG3NcHs
	Bf4zrCzqYmIJcrlVCdATnp1hFvuLHzUEZcMQpVvE64y76B4tt0+r25RgEET09+Iskqw==
X-Received: by 2002:adf:ba48:: with SMTP id t8mr14638170wrg.147.1549866861061;
        Sun, 10 Feb 2019 22:34:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVMZHhZuq671bWPkEQaT43RXznFr19zeEdNFXgzFqtXu1z4cX4aur/dS0AkVcCk2F+/XmO
X-Received: by 2002:adf:ba48:: with SMTP id t8mr14638126wrg.147.1549866860147;
        Sun, 10 Feb 2019 22:34:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549866860; cv=none;
        d=google.com; s=arc-20160816;
        b=Sl2zvnsi5wmMFy/Dzy5K3wyF2RPWHnL0Tv4w4qj1mNuV3KJd5+l5SsBulNHEpoa7ih
         cA0uRePEYXORmJnt+xOjx86+mmtE3NrUnUUsytv3Pq0Cjn/DMz94uO9L6ChRz74zS0iy
         iIKZfp6s/rtZb2KmDWo0bMv7Cidgq0y8sNHBHEG9zxuIjsS0mOR4XrM/OKI/ci6jSiD+
         wecP11xgRvSHR3TkpB5fnrtdPmFnCb30RiwYMkss1NzxBUEI1ecvsRi0MjeAXlK47wvi
         Ijl+eaiK9dh6f2jg23EVot8kGkaCFUvpNuqB2hj6Qk2tLk7HplXA80Lg2xlLb+amRPEU
         zFKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:cc:to:dkim-signature;
        bh=yxRrm7VICj3zaCZA5XwcFN8ealtHYWBMkDEcG+Ng+Sw=;
        b=oDRDaOUuIpyUAMdxdZO5Kd6cA6FTHn14E+aLJwSd4hHL2/W9xf+whSUCU2AoZwUckx
         QKd31n/dtg9a1NUL5Qg/WK+Ej2lGOI9bmQMK0rhb3ttr5izghE++mad6QZiOGQtHYnob
         EgVd55oaNjSwBariZ6JTyYmOwmvTBmIN+2hBQHFeSRrClGkdBauP0IFrp4phpjbXtpN0
         fokLtaKxIDUG+QcuoB4PAO4PuilHkvJleggDVBYwfGPInM8KVLs/ThuvNl6s0cgWC5vG
         ZXb3r7cy6ngj3U6jCQGSZaC44ej8qvi8cxMzUlu7JSOSgPQvoJa17mJwSre13xknfmr8
         tKiw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vexrQKj7;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l18si3131091wrr.197.2019.02.10.22.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 10 Feb 2019 22:34:20 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vexrQKj7;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Date:Message-ID:Subject:From:Cc:To:Sender:Reply-To:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=yxRrm7VICj3zaCZA5XwcFN8ealtHYWBMkDEcG+Ng+Sw=; b=vexrQKj7oP9VA079ZN7V1ZL0vC
	h6x359EpmPAavgXZYDHFfPC6R6pbEk/HLl1hhN/D8LO/DFo6HCJgtTEhtMGj+xE5GqtBknVhZ+jgq
	ZfA4wLbRXskVPghHiX5BIiXar5acy4VqhfmqrplcMbT1xaNq1C01J0sjKqLv7zKW3kTKGnH4Cp4bv
	fTAvwZrGtQGhKY707UaXUWip/WzuLTQOdYficN1dtqRvy02d23VE1wlfY4q6DWl9wr26dd7ku/JbX
	cMCBjZ8tec+cAl0goSi1vvIXTHnkRymPt88vlSJcEWAz6VaySK/0xsvp+cONHsmRu9RrQujqszc4g
	sJ6OgjuQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gt5AT-0004CC-Lj; Mon, 11 Feb 2019 06:34:14 +0000
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
 Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
Cc: Christoph Lameter <cl@linux.com>,
 Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] Documentation: fix vm/slub.rst warning
Message-ID: <1e992162-c4ac-fe4e-f1b0-d8a16a51d5e7@infradead.org>
Date: Sun, 10 Feb 2019 22:34:11 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix markup warning by quoting the '*' character with a backslash.

Documentation/vm/slub.rst:71: WARNING: Inline emphasis start-string without end-string.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
---
 Documentation/vm/slub.rst |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-50-rc6.orig/Documentation/vm/slub.rst
+++ lnx-50-rc6/Documentation/vm/slub.rst
@@ -68,7 +68,7 @@ end of the slab name, in order to cover
 example, here's how you can poison the dentry cache as well as all kmalloc
 slabs:
 
-	slub_debug=P,kmalloc-*,dentry
+	slub_debug=P,kmalloc-\*,dentry
 
 Red zoning and tracking may realign the slab.  We can just apply sanity checks
 to the dentry cache with::


