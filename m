Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57544C41514
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:47:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AC702339D
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:47:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ugedal.com header.i=@ugedal.com header.b="fM7h7Ro/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AC702339D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ugedal.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 987506B0003; Wed,  4 Sep 2019 02:47:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9393E6B0006; Wed,  4 Sep 2019 02:47:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84DB96B0007; Wed,  4 Sep 2019 02:47:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0035.hostedemail.com [216.40.44.35])
	by kanga.kvack.org (Postfix) with ESMTP id 63A056B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:47:49 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id EE554180AD801
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:47:48 +0000 (UTC)
X-FDA: 75896307816.22.meal37_6145ca108ca53
X-HE-Tag: meal37_6145ca108ca53
X-Filterd-Recvd-Size: 3471
Received: from mail-lf1-f66.google.com (mail-lf1-f66.google.com [209.85.167.66])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:47:48 +0000 (UTC)
Received: by mail-lf1-f66.google.com with SMTP id x80so3840933lff.3
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 23:47:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ugedal.com; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=VCpvUPnGtMaFPkKWpq/J1xLXz67crIRrfnDYom7vI1g=;
        b=fM7h7Ro/Da9WkUH/yjvTgbmcfpyqgsXqgsXMpf/v288stiaUjSytVzf1AFKEWqfC4Q
         dfWwvOPgLO1omPbDDVx+9013ZTdWFpJy+eZybOosvQUXXfuCAy5zm+A9++Rmt61Q64tA
         FgkZNJiV0QABtIiPLAt4+baM6Vs4uyY1iEqdO7WlqvOUIJRo61FsBaU2Li0hhiXJRSGH
         PldVQeDsENp+y/92d79U0uyGqPPSFEDp+0Lp9hDv4JpUWsSW6cCza/vmv/tcsqbDlAUD
         9kqc/YZWXoP7yaz2QY9lutn1Pd/34+ZrMiL6R7reWwLkA/haqxNURUGKoSZBZ1OM+DJX
         Ge4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=VCpvUPnGtMaFPkKWpq/J1xLXz67crIRrfnDYom7vI1g=;
        b=q3LNBs6hPubaHbUtaegI9kCyWvXvoyUAv0ck5uU7d83VZUxvhaQ/1Kcyci7r7qg1Dy
         YwVh35vuslDMaIJ7f/EuWGbp9ahAW4l3nkWhGgFDpkdcO7oOK2lfYHT/NabPr/GnzQqE
         gIsRu64iiNllaKZTuIUbV7WPqyfFeBIa91xUd9TK7uVvlOeva5agZ89wqxbCtPRoOdh4
         W4jFYPHfltVubSjkct+8yTzKmKs68+zzwFv8Bp9oAJCh6UEwfl159KlwZLXcgXlcWgHF
         ZegQc5zMg44RZb10fd9nDQy1SsCdOFjlEuGPn4bIxO/lseAVT1V8R1ZS9DI1Xrg27Gtx
         fFdg==
X-Gm-Message-State: APjAAAUxPAM+O0lFv/krKnHAHaldPawDxpdHZwAtwBtLWFn1VwSEZF6e
	pNc1phxotoXxogCga328pHgBOdAgbI2zkw==
X-Google-Smtp-Source: APXvYqzfFtKPoonHXM4AZdh4mJOJhhl2Y8xYGA+4gUVPiMpRz4I9lf1kZTJRY4o47kAPlzJLuuUN5w==
X-Received: by 2002:ac2:4a70:: with SMTP id q16mr9016716lfp.4.1567579666730;
        Tue, 03 Sep 2019 23:47:46 -0700 (PDT)
Received: from xps13.wlan.ntnu.no ([2001:700:300:4010:e6a4:71ff:fe46:cbe8])
        by smtp.gmail.com with ESMTPSA id a20sm3376721lff.78.2019.09.03.23.47.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 23:47:45 -0700 (PDT)
From: Odin Ugedal <odin@ugedal.com>
To: 
Cc: tj@kernel.org,
	Odin Ugedal <odin@ugedal.com>,
	linux-mm@kvack.org (open list:MEMORY MANAGEMENT),
	linux-kernel@vger.kernel.org (open list)
Subject: [PATCH] mm,hugetlb_cgroup: Fix typo failcntfile in comment
Date: Wed,  4 Sep 2019 08:47:09 +0200
Message-Id: <20190904064711.14490-1-odin@ugedal.com>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000019, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Change "failcntfile" to "failcnt file"

Signed-off-by: Odin Ugedal <odin@ugedal.com>
---
 mm/hugetlb_cgroup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 68c2f2f3c05b..3b004028c490 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -379,7 +379,7 @@ static void __init __hugetlb_cgroup_file_init(int idx=
)
 	cft->write =3D hugetlb_cgroup_reset;
 	cft->read_u64 =3D hugetlb_cgroup_read_u64;
=20
-	/* Add the failcntfile */
+	/* Add the failcnt file */
 	cft =3D &h->cgroup_files[3];
 	snprintf(cft->name, MAX_CFTYPE_NAME, "%s.failcnt", buf);
 	cft->private  =3D MEMFILE_PRIVATE(idx, RES_FAILCNT);
--=20
2.23.0


