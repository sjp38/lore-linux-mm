Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4829C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 21:49:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8046321871
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 21:49:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="FOT6Xd0x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8046321871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB79E6B0005; Thu, 14 Mar 2019 17:48:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3BB76B0006; Thu, 14 Mar 2019 17:48:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6316B0007; Thu, 14 Mar 2019 17:48:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7296B0005
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 17:48:59 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 43so6732922qtz.8
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 14:48:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R07u5PMAtEqJ4n0ZpRT11CGSzmXWRh5bYhsMopnK+pw=;
        b=RsBSo+YIz+6OsQ7ImcFmiik9rlnXLQoDbVA7zDJbFu79b2C3XLQW85Zxu1uTP4bNue
         2/3CCicPidPWRBQM2TSMPR9n2b6WpJ26L0Msi1cPt0vnTUkLm1UYXzEdsR9GQMuMi+lI
         650SzfOYlcWyIEy8LngDSUYANsPyEMwKHv3x1TdAMh7hnR1OaDDd0f2q3PsipQGqlUz9
         1NV8OASJYeSpiDml6ieXjwiua7FjMcgruD/ErSZIM1WTeZ4G1rufjdLIJSijsskYfl2m
         2WkPCR/L3/VFgyVvjRlWRNIkLgUJf9c3Unz6k304lep6nIXSBMUrPZljytdH35MytTy/
         NqBQ==
X-Gm-Message-State: APjAAAWhUzqYcpEG6AeMNDBv55o9899b0oIt+HhTvPibRn1hX5Kr71mv
	pRQslzE9tTW4F+jyl5bcuYhjAjYYuVjMc8SKiF1PTXtfrx8xH+ZjW0Sb3YhdDoP/c2ZPFzld23x
	cyR/kDWz6fcU9t/fC8wWhkdhGfVlUpkM9gSLmOTceGCkdqf2o/F+wF5NIt79IOrFfQQ==
X-Received: by 2002:a37:6bc6:: with SMTP id g189mr396970qkc.292.1552600139166;
        Thu, 14 Mar 2019 14:48:59 -0700 (PDT)
X-Received: by 2002:a37:6bc6:: with SMTP id g189mr396933qkc.292.1552600138434;
        Thu, 14 Mar 2019 14:48:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552600138; cv=none;
        d=google.com; s=arc-20160816;
        b=oOTaEDrw/TOl6z7SZWG7HgL2sS0SyCwkBS+US+kEejSV4AOYnT4rQuCmzW/UcYel54
         j9IhHYFUPQjQkmFGQ9zZAZBZsE2SctBPjPOozybLLu2qOzxQOmpChBeMt9Sit6Na3Guy
         +YAuQEATHFaHWnyoNpz3iueBZfMedIsr3498kaasxEnvOQls56eQkmerKcoQxJS7zS8Q
         l1ics/2p7AOg0ksPH+5afQ9M9ttm6cBZsrsemAavZqyN5ZYluH3Zaiv8vs1yw6Pamz2R
         oN1OlaRTbDruFWPyN+Yo63a1v/64E3iI+OI/2H1UeoNGVphP34aPG4gUdMVS0LdaRFhu
         D/iQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=R07u5PMAtEqJ4n0ZpRT11CGSzmXWRh5bYhsMopnK+pw=;
        b=oLF1e8PvglBNRarx+v/lOA7GXDtCn2BDxP6wJtgz9NZ/FNpkBMK+uG8vFTZzZ+DLwC
         zl47azcDpnOoKFNPJglrqq8ZT3KcRS9yLFQdqhDQhQirte2frkw+RwYVnBDUEmgg+Ov1
         Z8phVtXbkbRQuCZaOtNQ9QyEe8VLcgPGuQUKgE6uD1gTT06I8JSyP6qU6FHV56Djj/vl
         U17HD5V/sbVgly1ATNFWFsHjwwlgqXA0wrdPIxSYJlKR/gcMiop8d1zVWdUcMTc4KvPL
         mtv23AfGl3QpE14Ou91tb0kxjCX6L9VIqKZFxHEeCFb76ioeR9Fai8PIxAj6x63amYBA
         lzmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=FOT6Xd0x;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x199sor143963qka.12.2019.03.14.14.48.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 14:48:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=FOT6Xd0x;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=R07u5PMAtEqJ4n0ZpRT11CGSzmXWRh5bYhsMopnK+pw=;
        b=FOT6Xd0x/fkezE5hgpcd1utWlgralYJufRguBUibbEQEo07fzk8ZY1sZ4ZwS0efX+X
         MLfYwKLXkP0j9jVr08bvHJNhkbFwWd+Hc7WdwdwydtBVnJlZvk3O7FnLzugM2exCGtoD
         vhPZIzrBcO93Vjv4XFZgy9cxZUjBw3uGxCkyA=
X-Google-Smtp-Source: APXvYqwUR/6kJRQuB1DACGZpOWUAVhFSqYk8luZIxWo5LLt1PXgiPlMquSGzYzxYO3Z5hKRCvUEZkw==
X-Received: by 2002:a37:50d5:: with SMTP id e204mr428340qkb.26.1552600138133;
        Thu, 14 Mar 2019 14:48:58 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id o19sm96827qkl.65.2019.03.14.14.48.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 14:48:57 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org,
	mtk.manpages@gmail.com
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	dancol@google.com,
	Jann Horn <jannh@google.com>,
	John Stultz <john.stultz@linaro.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-man@vger.kernel.org,
	linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Shuah Khan <shuah@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH -manpage 1/2] fcntl.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal
Date: Thu, 14 Mar 2019 17:48:43 -0400
Message-Id: <20190314214844.207430-2-joel@joelfernandes.org>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
In-Reply-To: <20190314214844.207430-1-joel@joelfernandes.org>
References: <20190314214844.207430-1-joel@joelfernandes.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

More details of the seal can be found in the LKML patch:
https://lore.kernel.org/lkml/20181120052137.74317-1-joel@joelfernandes.org/T/#t

Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
---
 man2/fcntl.2 | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/man2/fcntl.2 b/man2/fcntl.2
index fce4f4c2b3bd..e01e2c075b5b 100644
--- a/man2/fcntl.2
+++ b/man2/fcntl.2
@@ -1525,6 +1525,21 @@ Furthermore, if there are any asynchronous I/O operations
 .RB ( io_submit (2))
 pending on the file,
 all outstanding writes will be discarded.
+.TP
+.BR F_SEAL_FUTURE_WRITE
+If this seal is set, the contents of the file can be modified only from
+existing writeable mappings that were created prior to the seal being set.
+Any attempt to create a new writeable mapping on the memfd via
+.BR mmap (2)
+will fail with
+.BR EPERM.
+Also any attempts to write to the memfd via
+.BR write (2)
+will fail with
+.BR EPERM.
+This is useful in situations where existing writable mapped regions need to be
+kept intact while preventing any future writes. For example, to share a
+read-only memory buffer to other processes that only the sender can write to.
 .\"
 .SS File read/write hints
 Write lifetime hints can be used to inform the kernel about the relative
-- 
2.21.0.360.g471c308f928-goog

