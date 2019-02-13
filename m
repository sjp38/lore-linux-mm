Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F4B7C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1281A222D0
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ULj+THdU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1281A222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA2D8E0008; Wed, 13 Feb 2019 17:42:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A580A8E0001; Wed, 13 Feb 2019 17:42:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 947D18E0008; Wed, 13 Feb 2019 17:42:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5548E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:22 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f202so923318wme.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=y4zotDQYnZoXB9lfg1fC2W7czb+qE54ZRjKDYZQbGrM=;
        b=KgplK5PAk5My2zFRWtPSW5mQ7OT6SvyLKkvq4Iz1eThKVhWhuyV+Ty4ZFU4FCZreMA
         H+JoL6+hyFOJiklmKUntDlIVCO1FQ8U/G8rQ2OGBIIuBQb2u4tXitA6EbhwPfISZ8iSF
         tyl+1SEiebV5CPZMhjN823NX316V44YysGaPAxgP2N6b/mG+9sx4rGypba7LWe2LxKTz
         042eZBnHJLmk0CXqB35N1pzld59iwMfmh5axyoMXSbfTSya738OAg1cE2rr7PNdHe1fM
         oqJntZfBxzHdl2oUSTzgyrYH5tQ6k6W90Vn5nNthST1ud50oBMdSXdld3cmMRzHFS0GZ
         E4mg==
X-Gm-Message-State: AHQUAuZmivQGQgPzDcHIGbirPAEZRAbXVqtsJjFFnImLbHnjGlucr63I
	V8JDxyKEYSkxwP9FlDnYpg3JHNxWmR/zHQKfSu9DCzy58o56y9nNPsBgJQAoAcwcw4AINv7X92o
	1XUZC6ulRnHBUCGpp6eJNR48jqsiwEFD6yGzoCNUsIr9gk3atKdU9q+5HsdWwjrMLVQmg6X3ZuS
	Nj7B4NYAZERlWvg2/6HEJXXQIrcJOQWKda0UOPrROHgiOny92QaPuCe35e3aoCWqdP3NU0YCUI7
	qXMKic88eZV/J3wxvwTGLIfm+MW6JPhS6VtG8VU/1q31HKTweX6RXMgwGHu4rhYHiNWsvW6H2cB
	uzL8Y+UpgNNq3c37XV3Axr6dXFLI+FWviKkzQh6XIBvjyF811cP/VPd9Mn8p3VhEnsAYPV0ffNo
	p
X-Received: by 2002:a1c:2804:: with SMTP id o4mr297675wmo.150.1550097741747;
        Wed, 13 Feb 2019 14:42:21 -0800 (PST)
X-Received: by 2002:a1c:2804:: with SMTP id o4mr297627wmo.150.1550097740465;
        Wed, 13 Feb 2019 14:42:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097740; cv=none;
        d=google.com; s=arc-20160816;
        b=bADH0q2r4FqbPDsGWtrl5ltOXVr8qiL2nKp8jh7Pev2ii16WSE6nfPh2Y0Lao04sZ/
         2YlaBECgjdoKUgZw7EfL+RvQw0XD0TTVVpzoL4I+Vv6a/3BLAlG/TaQ58BlyE3smkVA8
         Xh/vZaxj5rNoVE9MM3ZcSB9jF4sMdEfkWVEdROmyiW5GZyEMExrE1rxYUX4/YvHs/srd
         mIrLTetKMbIYROCXdzqjZopTCZP3OkwvBISChULoaGHQ5uwZzrDdsIuL2OfbSz9hYelw
         1NoKavSzmonY5EWvntcYR5uxF7IaP7XgoWAgGtIHQo1VI63ueQiJ6pDNtgTTgHxoHV6m
         e0iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=y4zotDQYnZoXB9lfg1fC2W7czb+qE54ZRjKDYZQbGrM=;
        b=E7wTyKm4rfI53WprjEn5T8s8vM04Z2JoS+XfXPVayqzMhLs6Urrcn56o0dEgFI9AW8
         33HvGTU9QRm69gNJ1HYYBxe+MR9reUhpP1n9eBLlTa0C7S0HXA4EDJB3tsDLuh+qnFPU
         NWGx1GNcN/aUYpZJD7nS5KJI6HWyAVZlWzRf17mm2nIXMTUYRNoV7cI+tVl+nqejMpqt
         PoG1w3dB0mAoyHBFzU8YF7xNW0nDF30UcOdveSLCdaTZox17bqUJNLROpdIeCHiLgCjL
         aez9JsHB2q2RYNLIPF3/OByvBI+czvnQTIUZ5xem8N7IJpHM6z3383QZfPDTxv2Qw5Ib
         L7Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ULj+THdU;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor369434wrx.39.2019.02.13.14.42.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:20 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ULj+THdU;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=y4zotDQYnZoXB9lfg1fC2W7czb+qE54ZRjKDYZQbGrM=;
        b=ULj+THdUZNWpGpW+KM463NwXvBXWj/ziG70TMcSMLTrDNndnvryzpWfDrOvQsAMlCy
         WTqTZgCLccOezugr9gkA0PatiHtL3QYcaVFHXdeDbHSfxmJnJ51XdhRFY2aUkbBgSTXx
         tipXJL3Dy6QXxBL3zVgPtPq1ANzRsbGAy0+TigONDh7YYLPUk1GGivftv1kHhyKzxr+p
         oyQSUS3fuoSUEsbw4S9g37thArexER13LrUX+3yjAYx3TqSBBIUg7eNLJ1ItQYMqyIY6
         X6RFb4SUKd44Df0ltx5kfaGf/joUGmooAumJyOgvpEFh9LCb/dYw4CmmbPPAwy2VlDMo
         0ODQ==
X-Google-Smtp-Source: AHgI3IYegSvkdqTo7yAMNGYKpTH4etQCyxzK1x4a5zwRFav668/1dvUCN1p823cxzwulFtPYhon3xA==
X-Received: by 2002:adf:9004:: with SMTP id h4mr302936wrh.49.1550097740125;
        Wed, 13 Feb 2019 14:42:20 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:19 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 07/12] __wr_after_init: Documentation: self-protection
Date: Thu, 14 Feb 2019 00:41:36 +0200
Message-Id: <f0335476914a519f573d271ef062dc02b39885d1.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Update the self-protection documentation, to mention also the use of the
__wr_after_init attribute.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 Documentation/security/self-protection.rst | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/Documentation/security/self-protection.rst b/Documentation/security/self-protection.rst
index f584fb74b4ff..df2614bc25b9 100644
--- a/Documentation/security/self-protection.rst
+++ b/Documentation/security/self-protection.rst
@@ -84,12 +84,14 @@ For variables that are initialized once at ``__init`` time, these can
 be marked with the (new and under development) ``__ro_after_init``
 attribute.
 
-What remains are variables that are updated rarely (e.g. GDT). These
-will need another infrastructure (similar to the temporary exceptions
-made to kernel code mentioned above) that allow them to spend the rest
-of their lifetime read-only. (For example, when being updated, only the
-CPU thread performing the update would be given uninterruptible write
-access to the memory.)
+Others, which are statically allocated, but still need to be updated
+rarely, can be marked with the ``__wr_after_init`` attribute.
+
+The update mechanism must avoid exposing the data to rogue alterations
+during the update. For example, only the CPU thread performing the update
+would be given uninterruptible write access to the memory.
+
+Currently there is no protection available for data allocated dynamically.
 
 Segregation of kernel memory from userspace memory
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 
2.19.1

