Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DA3AC3A59D
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DA0721744
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="cWRB2kBT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DA0721744
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9E166B0274; Fri, 16 Aug 2019 22:46:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4E4A6B0275; Fri, 16 Aug 2019 22:46:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF3D26B0276; Fri, 16 Aug 2019 22:46:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id A57906B0274
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:46 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 62088180C2E62
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:46 +0000 (UTC)
X-FDA: 75830382012.18.cow58_e276347a500
X-HE-Tag: cow58_e276347a500
X-Filterd-Recvd-Size: 5626
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:45 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id z4so8232660qtc.3
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Gnt8yazO3N8sExIXY3j+u+ZqminYZIsiqJs/+B6OhTk=;
        b=cWRB2kBTWh4/y+MMGqB3R/WWgZ7sLaFYtihcnoSwSt6r7xSqwl4+S+IhqH4xOnp0vq
         ySf3411CzGXNQBIcDU+KzwjgmaJLR7fVjhfDpEJc1SruBOh25M0jDoOVJaEMEKNOil/3
         hVbjYxlfCLhJGujq6rLK9H6BlMLoTORcd81nvMdoc2GpMEtVkgD/aXP06Luk6cE/7pE8
         AB7O6RFL6XiMdpb3vCKLa1UAsgPUVEnO7Rmp5pIjbq7MYSSI6BvECvUA2YzN0rp2JTgy
         j2Ay7njDh/dyDW5KG1tPtOgqTCJkiwYA7wdLnaoHh8kHEsapZh1ufoTOsXnD8g9n8gc7
         LJyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Gnt8yazO3N8sExIXY3j+u+ZqminYZIsiqJs/+B6OhTk=;
        b=YipcqCyFWYnQ27pUyCBHPV5iNbhEPPOJQjMq9I9mBqXz43Aor34JLCQTQHv4y8/enz
         a5/Hja26pHJ4nrTx3eCedM5IPZXTrp+ZYCmh/tbkZuRkTgiYVRV0VXOzZLTgB9C4NTYH
         cCcGoz6PZF6yiQeHxmO7t0ZdTVdzgtxeXfTATQ5pMg26Jeqq3cBcuOdgoSoPUKWUyCqF
         AW7X54QDOoZHe+tRmzEpc58Sn46+oTaQIOZNfPZ7q5jSe6W/ggO7XDWjoXRNE5BJsiLq
         m/7BRl4LUnmo3GKIuzdJi80MTl8kaVQ+W01fSEINJhycoVGe3zEBI+F8wtMTRnLWsf9Z
         pe3g==
X-Gm-Message-State: APjAAAV3SW6I4O0ZX4GN8t0Yi4jRkdC1qPVvovbtiuL59zfBuYBNhttq
	FeFzRo/NC4dZamOqKByhPGpN1w==
X-Google-Smtp-Source: APXvYqxszzLWkK2VLd5S53W8Fb3b8NJFaWMc7fwLM8sjAjZ7hGYnI41xlk+tqmjFr45dPKaJJpbf2w==
X-Received: by 2002:aed:31c2:: with SMTP id 60mr10402242qth.331.1566010005435;
        Fri, 16 Aug 2019 19:46:45 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:44 -0700 (PDT)
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
	linux-mm@kvack.org
Subject: [PATCH v2 10/14] kexec: add machine_kexec_post_load()
Date: Fri, 16 Aug 2019 22:46:25 -0400
Message-Id: <20190817024629.26611-11-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
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
2.22.1


