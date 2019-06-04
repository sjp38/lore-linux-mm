Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84298C04AB5
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C56A5261F5
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 01:45:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=eamanu.com header.i=@eamanu.com header.b="tf1RtB1Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C56A5261F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=eamanu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3599D6B000A; Mon,  3 Jun 2019 21:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 309B06B0010; Mon,  3 Jun 2019 21:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F9186B0266; Mon,  3 Jun 2019 21:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E61946B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 21:45:06 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id t11so9325845qtc.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 18:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=31D7tVoD27MFLLARXKuNb5xPGvmxkuw6aZuF+P8umRs=;
        b=Ks2flxf0rrAXzVw2FZOVWHUHVFD/NNCfIiRmEXQffZdI9iDoYyZd1Eigpvdy9a1A28
         3KDlrM39vAY++2HUDbXsKjEeVYcJjXQCcwOKL0qlFxYsUTcC8gUmRQMwTyNOvKaWCNXS
         TGVnf5HdDhB5md8uSomRVpAuaeUg6V+qDr6iaM4fBGaJM6ZYbYEx8HY2AUS1iLDERCEO
         rfI5BnQbEwv/vgzg5nvaF3A5wyL/sKyg+ppuxmylDyN55Zwancqb5YZmepu/i6BaUKTx
         ONejCDvExgUKr+kP+9NgfypylwcsiEiHehTsKmROJJxBE9PVQZrOgik4hkDEi44rryiH
         KKQQ==
X-Gm-Message-State: APjAAAWDkFAepxrMFUtSdW1Kcb8LaKzV/+UVVqQlKinrW1mioynM3yex
	Mgo10OSNvjfv/sgkbqXGQQTde9VhoBtWpoR96gUHkafIR3VTfa7bInmWGh9nrKRmctezJCVwO/y
	ZgZnu2BRAjcxyUZ4xdcp3o5OpvSXOh5vlWlxgnN7Y7cQtjhzvmit4xnFB5Lqa+Z1HUQ==
X-Received: by 2002:a0c:984b:: with SMTP id e11mr25071493qvd.174.1559612706486;
        Mon, 03 Jun 2019 18:45:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwB1ouS91P4eLVRn+ZSbYvvoiTNUX6D5NobVl+CIBfclrqgjqew8aB9DNzCUzCy4Iox12hv
X-Received: by 2002:a0c:984b:: with SMTP id e11mr25071445qvd.174.1559612705490;
        Mon, 03 Jun 2019 18:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559612705; cv=none;
        d=google.com; s=arc-20160816;
        b=HkuYSCxGhbqNKU5kbd020SessQYwaakuE+XmO9zjqYWh0O7qCNApvNwzTvnf9cxnlK
         PY3cES9V1esNCSb++rhEHGfS3EcHPvhl0KeGtfFluswebk+/Z9UsnOAavk6PM/fwuZ2q
         H8ku9KE0E+jU4/ajPujOadjyuGcIEU+CHMwNyXZOOpvAtt74EH5l/puAbJRLrZW/rp6q
         qs/SvkkPbrdd9mgOtMzh3AwBXbQ5FZA1Q6vOftKUMk4uep0VFTsPyLF9Y5vYzePWS1yt
         duVYNfpVp+VTPpmDb0qdAsrtyAWd670xmDtkNzwu2kgPdk5WK0qbV+8/kXWseYnnOtPD
         qxSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=31D7tVoD27MFLLARXKuNb5xPGvmxkuw6aZuF+P8umRs=;
        b=oidAG8WohsBrkXSLJMbRU9KtrvX+uWGdS6i2weJaon/RdHfrN4X+CF9gesmO6nYcIX
         LyOWf2wlQlEu2W7ETO/sQuCnQqr+mYX+zVg0vcgdEi44z86F7B2Ja3dI28qkbLJGzqzr
         VpzEB40YEvBHMV2ZfqrrS3hi7vXxUKVsF3Al5mnjEqNk1i4gVrxFV4v2zUBDvh8S9VTO
         oUSTvUIg2UWyOdI4ksVUhqKvXI0Hg4VwD0aHQ738zFuFtjD4mTbxIVOjheg7UBtNtW0F
         6Pz91rLF3PisKCRDlXGgBhmeOsASAciYgTd49WeTyUC3vulN5pNtBU7tlDlVjT5W1ib+
         TiuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eamanu.com header.s=mail header.b=tf1RtB1Y;
       spf=pass (google.com: domain of eamanu@eamanu.com designates 200.58.121.119 as permitted sender) smtp.mailfrom=eamanu@eamanu.com
Received: from smht-121-119.dattaweb.com (smht-121-119.dattaweb.com. [200.58.121.119])
        by mx.google.com with ESMTPS id s13si2185781qts.59.2019.06.03.18.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 18:45:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of eamanu@eamanu.com designates 200.58.121.119 as permitted sender) client-ip=200.58.121.119;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eamanu.com header.s=mail header.b=tf1RtB1Y;
       spf=pass (google.com: domain of eamanu@eamanu.com designates 200.58.121.119 as permitted sender) smtp.mailfrom=eamanu@eamanu.com
Received: from c056-dr.dattaweb.com (c056.linux.backend [172.17.110.65])
	by smarthost01.dattaweb.com (Postfix) with ESMTPS id 97279180007F6
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 22:45:03 -0300 (-03)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=eamanu.com;
	 s=mail; h=Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:
	Content-Type:Content-Transfer-Encoding:Content-ID:Content-Description:
	Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:
	In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
	List-Post:List-Owner:List-Archive;
	bh=31D7tVoD27MFLLARXKuNb5xPGvmxkuw6aZuF+P8umRs=; b=tf1RtB1YRBpojfXEtfpXtxpyTW
	sNuwQF7gRwwB9ncPJGSHrNu1zbEApakg1z9uqSs/gjokpEEYMZK8TUNmdwm8yoEvggeroOBoFst6i
	zsCSbKWkqRf8EXzuDmcFDyP+/sERrVvKLx8H4+oKhwmlWwvJF3lXm4b7KZPxHYaFZ7mQ=;
Received: from [200.55.11.99] (helo=debian.conectividad-cordoba.net.ar)
	by c056-dr.dattaweb.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
	(Exim 4.92)
	(envelope-from <eamanu@eamanu.com>)
	id 1hXyVX-0001z7-My; Mon, 03 Jun 2019 22:45:02 -0300
From: Emmanuel Arias <eamanu@eamanu.com>
To: cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	emmanuelarias30@gmail.com,
	Emmanuel Arias <eamanu@eamanu.com>
Subject: [PATCH] Make more redeable the kmalloc function
Date: Mon,  3 Jun 2019 22:44:54 -0300
Message-Id: <20190604014454.6652-1-eamanu@eamanu.com>
X-Mailer: git-send-email 2.11.0
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - c056-dr.dattaweb.com
X-AntiAbuse: Original Domain - kvack.org
X-AntiAbuse: Originator/Caller UID/GID - [502 502] / [502 502]
X-AntiAbuse: Sender Address Domain - eamanu.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The ``if```check of size > KMALLOC_MAX_CACHE_SIZE was between the same
preprocessor directive. I join the the directives to be more redeable.

Signed-off-by: Emmanuel Arias <eamanu@eamanu.com>
---
 include/linux/slab.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 11b45f7ae405..90753231c191 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -531,12 +531,10 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 static __always_inline void *kmalloc(size_t size, gfp_t flags)
 {
 	if (__builtin_constant_p(size)) {
-#ifndef CONFIG_SLOB
-		unsigned int index;
-#endif
 		if (size > KMALLOC_MAX_CACHE_SIZE)
 			return kmalloc_large(size, flags);
 #ifndef CONFIG_SLOB
+		unsigned int index;
 		index = kmalloc_index(size);
 
 		if (!index)
-- 
2.11.0

