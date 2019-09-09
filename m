Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DC49C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E76452089F
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:08:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tEqQBjJ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E76452089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95C806B000D; Mon,  9 Sep 2019 13:08:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933666B000E; Mon,  9 Sep 2019 13:08:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 849666B0010; Mon,  9 Sep 2019 13:08:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id 66DC06B000D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:08:37 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 16EBE824376D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:08:37 +0000 (UTC)
X-FDA: 75916016274.26.cake18_8560777087655
X-HE-Tag: cake18_8560777087655
X-Filterd-Recvd-Size: 3734
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:08:36 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id 4so8141987pgm.12
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:08:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=po3z9vVT8yU9vPmX7PJ6RtAkWylGnCZpE16E0o8CVfM=;
        b=tEqQBjJ3ODXxSMvYG+vcVbfl2luxsciSY2E+CsqLqrqbVjCNyZKwHecdfEmyUpgt3I
         uha/ukETxtto5BMjuu0dtOR0bYwM3A1N2k9GAforKbjH3v39Y5ea/j9ZpYQ3OCBTtK2j
         uwwuuHbyjZlL+Bx7dXXGCY658Q/G9QSrYzDYKb3Ns/Sw9adFXQ9rX8iGQvxXsa1RsP88
         g7wSH3FezbdWKoyybVGvKS9N5w3eDSsmPRcg5IznZHJC25aPpJlNTgg0dvd5BXWv71qP
         MdpLYxk3Aa1LfwYDJdCMXY7pgZS9dvze3XMZ/8A4hJesCTjq+iB8TYQ/DG3DsyNNxxEH
         CB1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=po3z9vVT8yU9vPmX7PJ6RtAkWylGnCZpE16E0o8CVfM=;
        b=jdgIGNfHpWxt1L3mkOF4N59Ig+8SisPRyvn8Lcv+WM+QfK2EMEo+i+SE0wmfQXFHhO
         LGPvX/J85KbS4Sv/ADOb0pAobRxAHcTBlmOluldWk1fYDS6A3MBEhQL20bpqWfql7HmF
         4DF7o0cWmmy76Qyw9PHnjMuG8Kz18FK7+O2CVGymXGlK66sk2Et4nmRzWenQaaP2pNrB
         XPuKXlnKWQuc4LOR3+sg2NYurksV2e1JDGEj8POEfd0F4EqKkwEL09Yph3KASPbHXjiR
         Kp4Xz+cijPA4Y+wlaYXlofs9nAxQv2k08GTVkXQtTexaNpgV5GYqQgYb/dfih8hY5222
         LQ7A==
X-Gm-Message-State: APjAAAUkE9ou/oJ9VM2cU0jv3JQ3N7HtSjPu9KpmlH1WcmoF265xhAgO
	6Ehe/KUZNyVEvvpKKjn5gDc=
X-Google-Smtp-Source: APXvYqw8nmtXQB0qB1NLHmAWDmBgZi64O1gEri+HPL1E/k/r0gZ67FyRjZJKK83eJQ2o5MKUrDATJA==
X-Received: by 2002:aa7:8d8e:: with SMTP id i14mr3798050pfr.262.1568048915686;
        Mon, 09 Sep 2019 10:08:35 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:160:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id b18sm107015pju.16.2019.09.09.10.08.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 09 Sep 2019 10:08:35 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz,
	cl@linux.com,
	penberg@kernel.org,
	rientjes@google.com,
	iamjoonsoo.kim@lge.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH v2 4/4] mm, slab_common: Make initializing KMALLOC_DMA start from 1
Date: Tue, 10 Sep 2019 01:07:15 +0800
Message-Id: <20190909170715.32545-5-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190909170715.32545-1-lpf.vector@gmail.com>
References: <20190909170715.32545-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

kmalloc_caches[KMALLOC_NORMAL][0] will never be initialized,
so the loop should start at 1 instead of 0

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index d64a64660f86..6b3e526934d9 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1236,7 +1236,7 @@ void __init create_kmalloc_caches(slab_flags_t flag=
s)
 	slab_state =3D UP;
=20
 #ifdef CONFIG_ZONE_DMA
-	for (i =3D 0; i <=3D KMALLOC_SHIFT_HIGH; i++) {
+	for (i =3D 1; i <=3D KMALLOC_SHIFT_HIGH; i++) {
 		struct kmem_cache *s =3D kmalloc_caches[KMALLOC_NORMAL][i];
=20
 		if (s) {
--=20
2.21.0


