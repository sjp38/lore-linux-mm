Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A9C6C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 426BF21874
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:28:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RiIwOk4Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 426BF21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DECB98E0198; Mon, 11 Feb 2019 18:28:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9EB48E0189; Mon, 11 Feb 2019 18:28:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB3358E0198; Mon, 11 Feb 2019 18:28:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77BEE8E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:28:29 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id m7so233014wrn.15
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:28:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=y4zotDQYnZoXB9lfg1fC2W7czb+qE54ZRjKDYZQbGrM=;
        b=dhDMM6VMi/JmH3+o0e+dDwzD3nPwjiM12Anzrk+e4C0NP8amX6LckJtujTNbtbXDfQ
         iH92sKATezcuVHmb0E8lGrH5nNdkZYM3zq8C8RKKF3r9h2D4dMuNv3mxiowoj6LRjqrL
         OFR4FyS/vt+ukGyv+LiI5IxLRaBm5TWRslLH0Fuyk49jGoHJLR1ZJ7P58wbjaMdLELqp
         peD8qLzQx3oP65NL2VbWaQn0cwY5FZCbhlelD04h/YF9z6drjPLrGaE/z/90w/Zb0ikb
         2ThhNEo+tRZu+a0v//xnAuC1ElbOiJnJbjM6mh6gpCzbe8krhQgp8TophFDsoaEVDOHw
         mXGA==
X-Gm-Message-State: AHQUAuYDXHKGnpWE6Kw5W0TaUJGLNr/Z5XheXEjZuEZwlEQbkiGgEayr
	VjG0KS+JA0wWlcB+BejB31cKRFxuojfXIOas2v2c0nMItPfdfzJrYDbp2xQBpCowcYxOlCU5OCX
	GMYPY1xGMN7oNJ57WXPmCvNuC7/37nLysYDhW/mzgsFDTkrw5SaHs3yyuQKtu7Z0HOu3XdahVU0
	Jws36ToZGnxeQBPOUH6g0xzhhhFq2CX34HPs7kavIgsB+6uQwVHrSvAk7XWd3iCHpTHV13PVN7A
	KE3RkqqddKbRlz2r6c2uDC4PQyf60HK9GzWsRBHC+zLBzNRnKldGLQ75p1r/0pNJa+/svJMGyJr
	5rqpdW5RLpzu1B/hUeJoldESLRBp9irldP9Tvr1/UV0Y0QX58XdYKpd9e8dweLbyGRqPH9qgorb
	o
X-Received: by 2002:a5d:4ccb:: with SMTP id c11mr486702wrt.241.1549927709010;
        Mon, 11 Feb 2019 15:28:29 -0800 (PST)
X-Received: by 2002:a5d:4ccb:: with SMTP id c11mr486664wrt.241.1549927707876;
        Mon, 11 Feb 2019 15:28:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549927707; cv=none;
        d=google.com; s=arc-20160816;
        b=GR1Cfpk9dEjDgxm6FJYi2ZJmfSN4k6wsy8nnpqf2St+7Kqur9ibgZrWm66G56OLmHo
         7oIH3mIdvp+hxnishR1UlYVW1koO3LW1IkYzKZYKz14vzuQZhccg5Zxh0ft+jhSgzW+/
         4cAU4TpmFj58P3cp1hRQMt5MH7V5wApvDI0P3g1J+3QKwWYYBojsl792MeVcWi4bEtYN
         2IGeRHqqTvBKZK9/85wd1kRelnhfN2Rezv30Hqf3sVsz63AOufLrvSRrvRBJ9n6ZFjTC
         IpGhV9orAuxMTaS0KySLbtNmiqB63WrmQ7bRh6Fy750Q6suAysznMqg3QAGmDfp3KCHX
         PZyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=y4zotDQYnZoXB9lfg1fC2W7czb+qE54ZRjKDYZQbGrM=;
        b=nMiBLVLZ2rXmUc3XQiVczGECK9nQA1lz7kFFvOOvHkP3k21q5oWbpiUSnT87gVA02B
         1844VzJVZk/BUplS5l0KxXUOtAzfRKvMTxJ1aPzA6khRSIRyQvfKJ+yDAg+lPef5MjEo
         ADZyrACvxwBGZCGVX7gZKRUOuHN8CQBKYl4DdTdBMO0aJ7tiFIevjjWGLNajoibXeyO5
         Eb72hLMNbaBIL0tleY3gHGCfayhuPjQPQyIZ+y6EuunQXnGzQsOYUpgQwzoEFShhOr+r
         P6e+gvT7VDPVCZ2ST+ClU8AD/W8Pmo/0Fg2g6UoRePXvXdVgox6veLuV9htq53CKuX6l
         +ZdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RiIwOk4Y;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor468988wmb.27.2019.02.11.15.28.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 15:28:27 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RiIwOk4Y;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=y4zotDQYnZoXB9lfg1fC2W7czb+qE54ZRjKDYZQbGrM=;
        b=RiIwOk4Yh3oZElR1xL4cASyYj7D6BXihLz4aCG/v4xszt7i6uSqsxIV7ytYwftyfcc
         uTuXGibwTiA/aj+YnMYCpkiM2z6kfso+3dbhiW9YSOHBl6nP1RszYI63KB8K2NsBpdrq
         0O12+xpEmBDUqkUXAPxb8OuavppC4Jr2y/PKJY27TEuHaKKz0cs5qLr1lY41XPnz7Zxl
         sA5IfuG6fAjiZmtxt25Ed0yZ2F0YDSgON1s7dC59J6yvzTcBnm5YPJLSt9XplPkdVRWQ
         K3g6xJSwVQiZphYA66q/CfA/tFG9bpv0/xDVALdXoiSGfJj+EbFGKE64OBFZr0dgUItK
         w5sw==
X-Google-Smtp-Source: AHgI3IYPC5M3Lyg22y71g2LtAl1fvg/0Ej4pQcQ/hIiBIm9wNMef0twZh8pcHX4//0/AZscOz8ApJw==
X-Received: by 2002:a1c:2804:: with SMTP id o4mr502017wmo.150.1549927707535;
        Mon, 11 Feb 2019 15:28:27 -0800 (PST)
Received: from localhost.localdomain (bba134232.alshamil.net.ae. [217.165.113.120])
        by smtp.gmail.com with ESMTPSA id e67sm1470295wmg.1.2019.02.11.15.28.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:28:26 -0800 (PST)
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
Subject: [RFC PATCH v4 07/12] __wr_after_init: Documentation: self-protection
Date: Tue, 12 Feb 2019 01:27:44 +0200
Message-Id: <cb930b9825a374126b62b897569cc722d3032161.1549927666.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1549927666.git.igor.stoppa@huawei.com>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
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

