Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D595C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60436216F4
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:32:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="GlTWlepJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60436216F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7088E6B0277; Wed, 21 Aug 2019 14:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6461A6B0279; Wed, 21 Aug 2019 14:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E8076B027A; Wed, 21 Aug 2019 14:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0034.hostedemail.com [216.40.44.34])
	by kanga.kvack.org (Postfix) with ESMTP id 18BC66B0277
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:32:26 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CE4838248AC6
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:25 +0000 (UTC)
X-FDA: 75847280250.30.name45_324688a753033
X-HE-Tag: name45_324688a753033
X-Filterd-Recvd-Size: 5660
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:32:25 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id m2so2701166qkd.10
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:32:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kCOV/SKGyCS/idoYOjNn3DaQRL2Ie2fUru8T4/v0tiY=;
        b=GlTWlepJvHyRbDlaHEFdDhjwr7ME6G3tgiH11e6zSHF0Yx3tG8+rX1LzQN9AxSvN5F
         eJHnR/A5iyS53ubpbQ7M2Rb0Qk3777oAjf3dYhxU7TssIsqeiE3gzsBsc9dNRK5JSwOs
         F3poSqq52q3oMa0JaQRQWhCbsmu3f7EurINkJ7fjV+5baUeM9/xWwhc1XLqecXGet8Ba
         ZpPa40huaT3e2j+zey0uLbMYFT1k0FKom6uI7dZJN69YlvG5TVagA+YBRsDBHENaAFPw
         VBZD6f/PTENBGtIIAdu1MbJ97QZQP0c/22pFDOAsvhBB7MgcQAQHsiaQkMXDjwSbIT+/
         ywIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=kCOV/SKGyCS/idoYOjNn3DaQRL2Ie2fUru8T4/v0tiY=;
        b=pOJuUuyTD55084H6uDy6ePXqzFQ/qgTHUsDTLXnFxcqJUFS0/lyiTXP2mnPuzEtd4H
         uqsNNJt3BoS8FMaiRa+b9vuIJp71ZFDmZw2k14JZ3ES1HWQjNNF29AwleNLd3fQvqeqh
         p3ynpPoxwnrfj2ab6gXDsCqEZ/9LhTW1CiuRushUqgyTqo4OclNzrNjaUuq3V3b5ZsWq
         x7lltGATdW3OOEyGMIpbYBIsif6gwf9zBrfI6IpSp4FOM//Z5PrNfbCm3qJdAW/eFxFd
         PfVc6jxsVC6cDABRAj1NF05yhg3exjKpDT+8RGklqPf7iSUopK/yDYNaHT9SjlsZxsTO
         14aA==
X-Gm-Message-State: APjAAAWHCn+xn54SMs9D2fFDhW7NwxFfm9Sgt4iCQdJfgC7boRRjXP1p
	jndKSqSTLQoakWRLsV+WL/he+A==
X-Google-Smtp-Source: APXvYqwt48uvxRp+EENQtSiynp6FQfq8H8l0y0bSzNIwyq4yP+ezYfhMfD/LoNrfv6n+23xSn0fbQA==
X-Received: by 2002:a05:620a:126d:: with SMTP id b13mr33824244qkl.452.1566412344835;
        Wed, 21 Aug 2019 11:32:24 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q13sm10443332qkm.120.2019.08.21.11.32.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 11:32:24 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org,
	mark.rutland@arm.com
Subject: [PATCH v3 13/17] kexec: add machine_kexec_post_load()
Date: Wed, 21 Aug 2019 14:32:00 -0400
Message-Id: <20190821183204.23576-14-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190821183204.23576-1-pasha.tatashin@soleen.com>
References: <20190821183204.23576-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It is the same as machine_kexec_prepare(), but is called after segments a=
re
loaded. This way, can do processing work with already loaded relocation
segments. One such example is arm64: it has to have segments loaded in
order to create a page table, but it cannot do it during kexec time,
because at that time allocations won't be possible anymore.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 kernel/kexec.c          | 4 ++++
 kernel/kexec_core.c     | 6 ++++++
 kernel/kexec_file.c     | 4 ++++
 kernel/kexec_internal.h | 2 ++
 4 files changed, 16 insertions(+)

diff --git a/kernel/kexec.c b/kernel/kexec.c
index 1b018f1a6e0d..27b71dc7b35a 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -159,6 +159,10 @@ static int do_kexec_load(unsigned long entry, unsign=
ed long nr_segments,
=20
 	kimage_terminate(image);
=20
+	ret =3D machine_kexec_post_load(image);
+	if (ret)
+		goto out;
+
 	/* Install the new kernel and uninstall the old */
 	image =3D xchg(dest_image, image);
=20
diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 2c5b72863b7b..8360645d1bbe 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -587,6 +587,12 @@ static void kimage_free_extra_pages(struct kimage *i=
mage)
 	kimage_free_page_list(&image->unusable_pages);
=20
 }
+
+int __weak machine_kexec_post_load(struct kimage *image)
+{
+	return 0;
+}
+
 void kimage_terminate(struct kimage *image)
 {
 	if (*image->entry !=3D 0)
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index b8cc032d5620..cb531d768114 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -391,6 +391,10 @@ SYSCALL_DEFINE5(kexec_file_load, int, kernel_fd, int=
, initrd_fd,
=20
 	kimage_terminate(image);
=20
+	ret =3D machine_kexec_post_load(image);
+	if (ret)
+		goto out;
+
 	/*
 	 * Free up any temporary buffers allocated which are not needed
 	 * after image has been loaded
diff --git a/kernel/kexec_internal.h b/kernel/kexec_internal.h
index 48aaf2ac0d0d..39d30ccf8d87 100644
--- a/kernel/kexec_internal.h
+++ b/kernel/kexec_internal.h
@@ -13,6 +13,8 @@ void kimage_terminate(struct kimage *image);
 int kimage_is_destination_range(struct kimage *image,
 				unsigned long start, unsigned long end);
=20
+int machine_kexec_post_load(struct kimage *image);
+
 extern struct mutex kexec_mutex;
=20
 #ifdef CONFIG_KEXEC_FILE
--=20
2.23.0


