Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D83C4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C283C218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:12:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="lGvVtacz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C283C218DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B2FE6B0008; Mon,  9 Sep 2019 14:12:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13F706B000A; Mon,  9 Sep 2019 14:12:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED1D46B000C; Mon,  9 Sep 2019 14:12:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id C6A696B0008
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:29 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 60FE48243763
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:29 +0000 (UTC)
X-FDA: 75916177218.03.door46_6cfca174a001d
X-HE-Tag: door46_6cfca174a001d
X-Filterd-Recvd-Size: 4270
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:28 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id n7so17275940qtb.6
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 11:12:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hIvv7JZmNGiFtMsjwPiXKldWZ14j/ed2TQl7Sv/FusU=;
        b=lGvVtaczZepcY3pVB902EwUXMLPY+wfRloMScgteToa6kMFSBvVkWpsD7vtQgvSnpb
         n/a54fuNHqwxUvxcFSzx0cdrSI3mvLlUG+wIbjNeDvCSbMpPXxVZiNC3frr/K8fEKaC5
         CexW4Wn3gLJtqbiGVGh4QhuREdkhbMZJsiQpyIH2GbgbDZWnUIFdVP9M4rfJSr+W/OqJ
         xfYnNoOEc6u+Yyu9eBmybePWEGSyM+5bPWq/2wFa59phJZztRB4Lcn61oUtH4Zxxm7uW
         hyvJXiag0PQpx5U2WS0yHf8InIp947VYjVgAUFFyWL9SJvJ/5W880Im12Kt7v3afQCVJ
         EQbQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=hIvv7JZmNGiFtMsjwPiXKldWZ14j/ed2TQl7Sv/FusU=;
        b=IWe64BchgOUYFQQwd5uWNCWntKRe+ib8cA4juVzH24eY+X7eWnH1OXCyeWXLeWWzUw
         9e8Wvni5Kl2BEO9FFLMjcIQozcu9lL10g02dUYHqAFFtklmkTkAZpBkB14Fb/lerPKvd
         lZMhz30VcO3eVjVVQQ0LMAQmH721nC56uhqTRfhgIUNbaBgLvXPirTPhux+EB/O9wp0V
         vviETz94vjC+JlgyWNWteEqKe9BSSNvN7cRh+IXmNBIujglSyTGp21pioM8+EHuQUxBV
         0dAzxIf9ByG+VZ2q3GjDCrLJFQKLjKcIMGb0eQ0WFoxk6cZxrFRFyPCVGBAWaIADk7lo
         Q5DA==
X-Gm-Message-State: APjAAAUmIcgwOiFOHeNBLDF3iUxx3z7lziCoYMT7eHP4C63Ss453bBDG
	TKggiRlplTcQewrssiuEecfThg==
X-Google-Smtp-Source: APXvYqzqCGrV++beTKTDQJdhdQgon7XutZsT6/j1WY0FvUCkwan7YuQ95/1EShbY3LwmpFjAnArpdw==
X-Received: by 2002:a0c:a0e6:: with SMTP id c93mr15594165qva.109.1568052748291;
        Mon, 09 Sep 2019 11:12:28 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id q8sm5611310qtj.76.2019.09.09.11.12.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 11:12:27 -0700 (PDT)
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
Subject: [PATCH v4 03/17] arm64: hibernate: check pgd table allocation
Date: Mon,  9 Sep 2019 14:12:07 -0400
Message-Id: <20190909181221.309510-4-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <20190909181221.309510-1-pasha.tatashin@soleen.com>
References: <20190909181221.309510-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is a bug in create_safe_exec_page(), when page table is allocated
it is not checked that table is allocated successfully:

But it is dereferenced in: pgd_none(READ_ONCE(*pgdp)).  Check that
allocation was successful.

Fixes: 82869ac57b5d ("arm64: kernel: Add support for hibernate/suspend-to=
-disk")

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/kernel/hibernate.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.=
c
index 025221564252..227cc26720f7 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -217,6 +217,11 @@ static int create_safe_exec_page(void *src_start, si=
ze_t length,
 	__flush_icache_range(dst, dst + length);
=20
 	trans_pgd =3D allocator(mask);
+	if (!trans_pgd) {
+		rc =3D -ENOMEM;
+		goto out;
+	}
+
 	pgdp =3D pgd_offset_raw(trans_pgd, dst_addr);
 	if (pgd_none(READ_ONCE(*pgdp))) {
 		pudp =3D allocator(mask);
--=20
2.23.0


