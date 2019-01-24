Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E4C5C282C3
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 07:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C370D2184C
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 07:00:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C370D2184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E34D8E0074; Thu, 24 Jan 2019 02:00:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26C198E0073; Thu, 24 Jan 2019 02:00:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 134F58E0074; Thu, 24 Jan 2019 02:00:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C17FD8E0073
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 02:00:43 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id p3so3293887plk.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 23:00:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=CYUiRNDHNFLjI8G1oBswFaxm+z/4kVqD2NsTsV/kvQY=;
        b=bElTvctgWY+XBFMPrFQDuyRukIcrEYIwELvw7ImWV2a57GA1hS7oWEKmAOuRDj58Ny
         KCAtbVdN0kbllz0qa+4cC7/j3cRtdDvoAjgYHSRdzgME6aHD/Tnyfo3J8l9gK7g3VtRp
         zYYAUleXFJeVcEtNeAfpFhczXNUA6IBjcz8RmdoQpLjqCF3ql3PtXjk8nIMr6y2AvL0U
         gK32MUWIGWa0OibRjdXOcfiu0xmc4O8I85W3nXJGrPTPxIScCkmBbIQT4zGY9eZtknaJ
         ZZLEmWeAMWMycqrUkVFaCl6A090H2UIG+DnYIMEyWmzjgUcSt2clznfeI+aW/yhBoPIV
         d3xQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-Gm-Message-State: AJcUukeIoJm/ckC+t2gc58y/ooL/r0lC/BS9bNayJ2pRlX6+DJsHEuMu
	+YcGcpCE0xr0/asfOM4czlYudMxbEl/+V1xqga9wppaedRmnJ+ahc0Iwbj5aT0Z6Zb8LLztyl3T
	G2wNmvNLBGzDHy190rz1AjVzOVV8vv0RzIAzLrQrV/u3hrf+Mw7WayrpqfTIpWS+1SA==
X-Received: by 2002:a63:2054:: with SMTP id r20mr4854041pgm.328.1548313243370;
        Wed, 23 Jan 2019 23:00:43 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6ouZDxEHgswqP6uHGHW2DWLb+oevDHaxqtByHaHQ5co2ZuLF/DjW3RPQFyGcSt0abOTJpy
X-Received: by 2002:a63:2054:: with SMTP id r20mr4853984pgm.328.1548313242508;
        Wed, 23 Jan 2019 23:00:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548313242; cv=none;
        d=google.com; s=arc-20160816;
        b=WzIKb00ISeWJKpQzTIZ8Vp0EWMO9MR10rDR7niXPHFut1n2ZBRdc3XgyMUwvn+Gh2a
         BFWUaFjOEs8h6RTw/jMzIYJ9EztZ2dI1k4KboHODIaS8AUTqmOSYztjyYb++PLS5GUci
         zxZSVC7uavVRIXY0YHrYOfvACgKauvjVWtrbbV0wc0onAXa3XCFLNfGiD9EL5BlySkma
         YLhTE0wy4nSiEMvM0oiE759Q/NKAib+3smzPZw5FIRlG+7bEyhRCymuPf/Ka8S62I9we
         v1zhGZ/4c3SKbSpAgM7lRsa5O677oBhYiz0bq4garzQgvqRa2OQ/SQg1UdAoGbBc1Ve8
         2jfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=CYUiRNDHNFLjI8G1oBswFaxm+z/4kVqD2NsTsV/kvQY=;
        b=mp3/IRmiJ1U3YgV3cIi0DYp4K6F6vjpSA47lFbvXMbDaVQj0JJBbk6pFKsguyKlN0o
         leyQOLqBsQqIRIcYEq8BBjiZuQgX0c8t93AJUChqXNcrKmsF5JKn9kugovzt854tGgvg
         Be4OELVdAT2Imcgx2TS/nG7TzpkfYes6jfHYUXhdIz0aWpeGiHRNnWeZQF3nN5C6R8/3
         QAnpEzkkeIjr/bMh9bvT5BCS9KOUjA5psAWE9DTHpqXBtOppi2dJFWxwo6gCkfmjwiUW
         HwceoBNAb1m+dNhens5o5qvnjj5xC0/tVkmoCN3wRTvgw5+o8tYYV2NVwKjkDsADanyV
         uwrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id 102si11499284plc.277.2019.01.23.23.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 23:00:42 -0800 (PST)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-UUID: 5d713484814042e1a9c6ea1fef697536-20190124
X-UUID: 5d713484814042e1a9c6ea1fef697536-20190124
Received: from mtkcas07.mediatek.inc [(172.21.101.84)] by mailgw02.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 667523100; Thu, 24 Jan 2019 15:00:32 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs08n1.mediatek.inc (172.21.101.55) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 24 Jan 2019 15:00:24 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 24 Jan 2019 15:00:24 +0800
From: <miles.chen@mediatek.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	"David Rientjes" <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	"Andrew Morton" <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>, Miles Chen <miles.chen@mediatek.com>
Subject: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
Date: Thu, 24 Jan 2019 15:00:23 +0800
Message-ID: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
X-Mailer: git-send-email 1.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190124070023.OVb2N567rm7d-odGq8w7hLJEfjFl7PN0NpW8F4BDFlo@z>

From: Miles Chen <miles.chen@mediatek.com>

When debugging slab errors in slub.c, sometimes we have to trigger
a panic in order to get the coredump file. Add a debug option
SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.

Change since v1:
1. Add a special debug option SLAB_WARN_ON_ERROR and toggle WARN_ON()
if it is set.
2. SLAB_WARN_ON_ERROR can be set by kernel parameter slub_debug.

Cc: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>,
Cc: David Rientjes <rientjes@google.com>,
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 Documentation/vm/slub.rst |  1 +
 include/linux/slab.h      |  3 +++
 mm/slub.c                 | 34 ++++++++++++++++++++++++++++++++--
 3 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/slub.rst b/Documentation/vm/slub.rst
index 195928808bac..236c00b2d17b 100644
--- a/Documentation/vm/slub.rst
+++ b/Documentation/vm/slub.rst
@@ -52,6 +52,7 @@ Possible debug options are::
 	A		Toggle failslab filter mark for the cache
 	O		Switch debugging off for caches that would have
 			caused higher minimum slab orders
+	W		Toggle WARN_ON() on slab errors
 	-		Switch all debugging off (useful if the kernel is
 			configured with CONFIG_SLUB_DEBUG_ON)
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 11b45f7ae405..1fd9911890c6 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -109,6 +109,9 @@
 #define SLAB_KASAN		0
 #endif
 
+/* WARN_ON slab error */
+#define SLAB_WARN_ON_ERROR	((slab_flags_t __force)0x10000000U)
+
 /* The following flags affect the page allocator grouping pages by mobility */
 /* Objects are reclaimable */
 #define SLAB_RECLAIM_ACCOUNT	((slab_flags_t __force)0x00020000U)
diff --git a/mm/slub.c b/mm/slub.c
index 1e3d0ec4e200..60f93e0657fb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -684,7 +684,10 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 		print_section(KERN_ERR, "Padding ", p + off,
 			      size_from_object(s) - off);
 
-	dump_stack();
+	if (unlikely(s->flags & SLAB_WARN_ON_ERROR))
+		WARN_ON(1);
+	else
+		dump_stack();
 }
 
 void object_err(struct kmem_cache *s, struct page *page,
@@ -705,7 +708,11 @@ static __printf(3, 4) void slab_err(struct kmem_cache *s, struct page *page,
 	va_end(args);
 	slab_bug(s, "%s", buf);
 	print_page_info(page);
-	dump_stack();
+
+	if (unlikely(s->flags & SLAB_WARN_ON_ERROR))
+		WARN_ON(1);
+	else
+		dump_stack();
 }
 
 static void init_object(struct kmem_cache *s, void *object, u8 val)
@@ -1254,6 +1261,9 @@ static int __init setup_slub_debug(char *str)
 		case 'a':
 			slub_debug |= SLAB_FAILSLAB;
 			break;
+		case 'w':
+			slub_debug |= SLAB_WARN_ON_ERROR;
+			break;
 		case 'o':
 			/*
 			 * Avoid enabling debugging on caches if its minimum
@@ -5220,6 +5230,25 @@ static ssize_t store_user_store(struct kmem_cache *s,
 }
 SLAB_ATTR(store_user);
 
+static ssize_t warn_on_error_show(struct kmem_cache *s, char *buf)
+{
+	return sprintf(buf, "%d\n", !!(s->flags & SLAB_WARN_ON_ERROR));
+}
+
+static ssize_t warn_on_error_store(struct kmem_cache *s,
+				const char *buf, size_t length)
+{
+	if (any_slab_objects(s))
+		return -EBUSY;
+
+	s->flags &= ~SLAB_WARN_ON_ERROR;
+	if (buf[0] == '1')
+		s->flags |= SLAB_WARN_ON_ERROR;
+
+	return length;
+}
+SLAB_ATTR(warn_on_error);
+
 static ssize_t validate_show(struct kmem_cache *s, char *buf)
 {
 	return 0;
@@ -5428,6 +5457,7 @@ static struct attribute *slab_attrs[] = {
 	&validate_attr.attr,
 	&alloc_calls_attr.attr,
 	&free_calls_attr.attr,
+	&warn_on_error_attr.attr,
 #endif
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
-- 
2.18.0

