Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38B73C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 09:27:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E28F820854
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 09:27:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NlnQ0maU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E28F820854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A17D6B0005; Tue, 19 Mar 2019 05:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 951556B0006; Tue, 19 Mar 2019 05:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 868746B0007; Tue, 19 Mar 2019 05:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DA3C6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 05:27:57 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id i4so16876462itb.1
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 02:27:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=EOsSTBRP/BshLjDVZ1hXKQzf74hkqz+KxF8DK7oDS3c=;
        b=rPcDrsuRB5ZlOvGUUQ1vMv9xO8PwEnrOPNrojNVu5ttg8FaIAXWitvGRI1WItV/4xS
         1A66+tPA7iQgQjuKajL+uPneaa/qoHaAOXxXZxjcm59feoQh0RpT278zqtdwIQ26W7jI
         qSYU7dNF9u+FMOnmGlrug7V6R7MrxqzzEdA79h51v6hfQ0oDEQQ2edBiUHFycHo4cPa/
         2D94RT+BY32jBzt4i0HzPXg7P5MtiouQrvTQIdlhh9m8u9OM1nEdl+1yqig8uH7MSwlw
         XVzwZPBudnKCH+MKwMJgySPy4NykLH3RXjaKxRlJyJN4rqwLKfQwwPOcpL1bCGaOdlei
         pXtg==
X-Gm-Message-State: APjAAAV09tmbFsUZCxWmWEpKTLXf/ICplRy+D8jv2CtR4JyHhOlueUpz
	GT5rAG0kYRZI/QTmULCn25oDQWUmY2IbOX2/+1DuMAeTa5yCEN3+zz+nlhABEbwlamz05Hi8kcH
	855TyisbS1l4G1p6KyWS6Zid81nJoObSUFpM6k2SVqOeKoSCcH/N2fj2intkxNpOfRQ==
X-Received: by 2002:a02:4c0c:: with SMTP id a12mr753566jab.126.1552987677082;
        Tue, 19 Mar 2019 02:27:57 -0700 (PDT)
X-Received: by 2002:a02:4c0c:: with SMTP id a12mr753538jab.126.1552987676235;
        Tue, 19 Mar 2019 02:27:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552987676; cv=none;
        d=google.com; s=arc-20160816;
        b=q6R7YllKInkb44tE5QYezUly2CSMYsrnos06xZetlyZ1NGAEjhLu/+gMAXlCMRMl48
         BxJlmXFvgZv3CSi0paZ4uIJzgaTx2qX/LpoEw+sW3OBFYUgLrg3n7abqKQsH9nvKIpHM
         lpymDEmfZTeUV2aTjSq/EjDsWybd1STUPd5EfE1EZqGH3e5B9pDAz3FDeSOBmfApwW/k
         pt5fKS5aHNmowbenNMC5033IwKU2QXeZQZmKE/9Uud2gM6m40i9INsGymmdy0h9XQpyL
         CUIfV3nDBWUSEwveps6w1YaNW4pgwc6xK1HMlww4QhemW8gz1gF8GQCIRK/7IQjyfqtC
         y+3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=EOsSTBRP/BshLjDVZ1hXKQzf74hkqz+KxF8DK7oDS3c=;
        b=XL+MW4sWII6xxRyxJgp7n7nr93lfdMfL2JGBsKWB9f5e4r7ihqBI50VumEHLgr1MLm
         sHsBChL3qmArOxAiA/m+CuoNhVYk36HzJsLOzvkAxrzAxOaOeLVQCiqUqjiujOoX9Quf
         6rloAQfxBTInbKmD8Ith7ehGZabGYo+dw+ntemjfL/9joJKxcwKtQ/74TGFHHcuirqAc
         UHutejy/Rg7uX5krvcZ0aSkXcpv6NKTBKmG/l9zpwjknJvcAEcYxWmUsAZGwetEuU1V2
         tsSSjsXpXDX+wbZKN2ZY3L2jYHCDECdnZUZuzQCMf80zb7GDDnofMyAXsSqDOvYmSbai
         WvzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NlnQ0maU;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y20sor5791083iol.11.2019.03.19.02.27.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 02:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NlnQ0maU;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=EOsSTBRP/BshLjDVZ1hXKQzf74hkqz+KxF8DK7oDS3c=;
        b=NlnQ0maUX/zcIaP00WrgXKa6TeYY5kwU6SeREdwWgiTRpqplfXKyQEdRNdD6euJwmq
         HWCa2DAgXaRZ/qO75/JOz614V/F5JFEYlkYKEdHbZ2GkBNt/1a3v7PSMyB6MeOi0XMQd
         DLIbcumJ7GGB5YlcJ4Tot4kJJE8sUPCsTBedmpnwBMd+cwuD+XOKxB8kWoSgVlxyEXsE
         kJtXn4RTMfm5D8qArD9k75aEJtDcPge4hUw3aAX4MX2cHzNoKfvo+XXC8zIKlZbKwcjp
         uxxO/CP04U4U+dUNFQhGJtXoQeoo6f2k44pHjcA2fcWwsZsHxE0cepw0yLo2+9uu/LXh
         sqgQ==
X-Google-Smtp-Source: APXvYqzZCcDn3wQPMJQjzN2dd77J1WuJd0znBkD/vrveAlx8QXcOEyqcigqs2eABgYisnwexCodo7Q==
X-Received: by 2002:a6b:6d15:: with SMTP id a21mr674374iod.235.1552987676045;
        Tue, 19 Mar 2019 02:27:56 -0700 (PDT)
Received: from huyue2.ccdomain.com ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id 127sm1122362itl.25.2019.03.19.02.27.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 02:27:55 -0700 (PDT)
From: Yue Hu <zbestahu@gmail.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	joe@perches.com,
	rientjes@google.com
Cc: linux-mm@kvack.org,
	huyue2@yulong.com,
	dongjian@yulong.com
Subject: [PATCH] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Tue, 19 Mar 2019 17:27:34 +0800
Message-Id: <20190319092734.276-1-zbestahu@gmail.com>
X-Mailer: git-send-email 2.17.1.windows.2
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000880, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

If not find zero bit in find_next_zero_bit(), it will return the
size parameter passed in, so the start bit should be compared with
bitmap_maxno rather than cma->count. Although getting maxchunk is
working fine due to zero value of order_per_bit currently, the
operation will be stuck if order_per_bit is set as non-zero.

Signed-off-by: Yue Hu <huyue2@yulong.com>
---
 mm/cma_debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index f234672..3b69248 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -58,7 +58,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
 	mutex_lock(&cma->lock);
 	for (;;) {
 		start = find_next_zero_bit(cma->bitmap, bitmap_maxno, end);
-		if (start >= cma->count)
+		if (start >= bitmap_maxno)
 			break;
 		end = find_next_bit(cma->bitmap, bitmap_maxno, start);
 		maxchunk = max(end - start, maxchunk);
-- 
1.9.1

