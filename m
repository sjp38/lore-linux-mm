Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E64BC742B0
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:17:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BAAF2166E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:17:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BAAF2166E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E98EE8E012F; Fri, 12 Jul 2019 05:17:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E48FC8E00DB; Fri, 12 Jul 2019 05:17:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D101B8E012F; Fri, 12 Jul 2019 05:17:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 803BF8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:17:25 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f16so3994062wrw.5
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:17:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=nh45F2PS0uH+h2wY6iFXunuS7WHkwtGS4SjL6R9jQCk=;
        b=Xs8YaM9zM/bdmKeyt9zzUqiuIBjS+3xJxqH2KTun2Eh7092cTsIqixZ5KPh5KWT7/b
         27EiBJqv0hMyHi2rbHfROCXSsTbm1sJFg8JvYwqJ9iJK6hSf/JEqZuDl80ewD1eUKa8z
         1t4a9JI90vRtIDtfIvjNaUXWD4UvHOuP46YvHNwQQ2zQwNmcLL23LYJSWl8LdhjZ6tib
         k3k15/Vt/vQ4vQ2+2OP0pBwYidP8NtBSdTMRuSMnxRxm63VSVCqGxecuhv3Ip599/4DR
         ho8vDhLKmhvFz2keaZ+2HrTL7jjfEuooa5GiDpXvsNBb3At+7vcQ/OwPOih3OU5a+Puy
         qtdA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAUkdMDVGmEyP2kfK8KV8mEeenCBq5dlCjDhwWFAn1mmrgbnDIgq
	BlMFSQeeUXT8XeruWf3ytquOmvKDk0eotDTKb0qEM3agZG6h9lhTEpUPdQ5skVCnEG86b4zr7TC
	WJVB714jdwkky5VP74EIcktleXzcaXh1XpipYsnI39ntNs+Ud257j/x3De9961cU=
X-Received: by 2002:a1c:1f4e:: with SMTP id f75mr8579668wmf.137.1562923045051;
        Fri, 12 Jul 2019 02:17:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj60BGsmuaX/w0ImCKoAFMlvdxQpnLfSwicZxUcQt6bkZSK/Ofkza0bFPbFWN00eykqVJm
X-Received: by 2002:a1c:1f4e:: with SMTP id f75mr8579571wmf.137.1562923044208;
        Fri, 12 Jul 2019 02:17:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562923044; cv=none;
        d=google.com; s=arc-20160816;
        b=AkRRx0HtqaZDe5UNM6OOQZlzkMHLtQCKcq2h34jeHOlFSKpnabuc5oquY5Dq+UdUNl
         HfIhpwOkh/X/lsvE6UNiAvm5sPZ251NJt8Frf/Qzph7e9BeEjsKDz5CmO8jO06rv4h4z
         18WD9yxlp1zGEMUx6ZSCvQ+gZ1/RcscDu6n7fNW23XHADFYVnxrEQKbeYAVaUUoGMdih
         /Yo/lO9cCEIUQpsnFUnF+4M+0LJr48GE6SAhdpzOoXXEdZzu6LXE5hKQnXZFlPVVw7tN
         r8qZXbyXH5fdSWGX/2fYq5+4LqQo/PVpJPZeju4dae9Bpln0Z9ynmmU6w0Kkick/HVFb
         FvvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=nh45F2PS0uH+h2wY6iFXunuS7WHkwtGS4SjL6R9jQCk=;
        b=X+XCTAMzJHiSe4u+rziFnoHenj7rY70k01TJoWBLbONHK99Md0xzRqOWb0SO9VZgPg
         smyrPqJe771z2HQcbW3kWlch1eaHN84Pg/dNGiV1TSfWelJ2YJ9GEI3J6/h2epp/tg/u
         br5Pl8b9F5OHQuiuanHYVsMT0pAXO1lBOzWJGP8ntSXMLQnsDYnde6BT2xYs4TdolfMO
         ZdIvw4Lfs0kX7wurVwVUal6gzl/GL+nYRkw1PIsJz2tcjolI28aRslChB9uS4IuIajrG
         jTZMKMrc2VRuWv77YiA4ZRh7DP20TUFwTy8fdxQpPdVdwXniKBpNs/8aMaWE/7qgsig6
         XHCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.133])
        by mx.google.com with ESMTPS id m13si8145076wru.8.2019.07.12.02.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 02:17:24 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.126.133;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.126.133 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue011 [212.227.15.129]) with ESMTPA (Nemesis) id
 1MnaTt-1iDnxj0N1B-00jd8T; Fri, 12 Jul 2019 11:11:50 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Hugh Dickins <hughd@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
	David Howells <dhowells@redhat.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Vineeth Remanan Pillai <vpillai@digitalocean.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] thp: fix unused shmem_parse_huge() function warning
Date: Fri, 12 Jul 2019 11:11:31 +0200
Message-Id: <20190712091141.673355-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:2eYIEw+FuGFLaFFnKIH/ts58p8jvvELIVRGUWlzkTykX3ykX0/v
 ts+nAn49miAUJt8DvK+mqbmcyi6PwAVzbh9XnS5MWrU1+0O/eSmcmtzcL9ONUd/zHoqYZcr
 fsERZV6Xr78UtnbuWoFCE8702Z6CLbbbh8uTN8jvzkak2k/Uz76hgbkwxo/Sl1gDg9Wr9RL
 vH2DwCgQDpxF8RtsHhT/w==
X-UI-Out-Filterresults: notjunk:1;V03:K0:MFLRiRfyKs0=:y3WLnaB3wWK7ZVw2+uaZSz
 KDWyGJ16nm4B9n08VOCzmdw4CqtSZ8X7gK9dT8fb29QCvzDZL+7Csbn7GuN+HVETkTycalpoE
 O4/TtwxB/r4kvi77kMOAkPvuPgA5561YoncV7xlx02HMH20ikp4gMDuKhRVDCc609+CJOaWCa
 V0kf/q6ETmUeFUGBiyMHn8goumYpJbC/s1HrAnPO8VekBzolBs4uIXJy87vCakBG0GYTtm/zX
 sDC8gfNtaOOH7lCcs/cihf/aes6gQFxARedS6PvPJSzd2azf/PhDooB6mRllY933D4Ms7IJ5j
 ZW1pENKTBaAGZI2iXNPB+VBWo6qFCntnmK+AnHHb0Y7eowif+xHEPv3BW0zDU4kZjFJAfVfkc
 AxJcFdxJ/OMGbPIcrDul9jy69nhaOK74SIm/UMIZvdF2H6ciSjrT2tBm/3dzwXJlczODx/1zL
 AV9TKdL/mS4MfSExx+QvedR4HrVf7wNCNP2T5nDS35jspJFmBMc7il2juByeIsVtv1Fgau6oN
 fccvQhaZblRROnjXP0bzSett+3mfisO3X7stX4Y7Qmy0SW2YRYNW+tU5nHuQ6bTcN9D5PUdKU
 Olq2To7gnj1xvDPouxrauUTHaIS/MXs53f5TSCIqF/POLGX+svJVqkYndKQB71i3w69mr7MRp
 WNKoqGgNBN3kBXBkURgDUo/qeaS3+WVNgQOSCjg7XGBg3mrVvl0JhohthgDjh5j1yrBDzZZSH
 26RrhyCtiRa3NwjLqvDBKTpQXjouaJbtK4ZBvQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When CONFIG_SYSFS is disabled but CONFIG_TMPFS is enabled, we get a warning
about shmem_parse_huge() never being called:

mm/shmem.c:417:12: error: unused function 'shmem_parse_huge' [-Werror,-Wunused-function]
static int shmem_parse_huge(const char *str)

Change the #ifdef so we no longer build this function in that configuration.

Fixes: 144df3b288c4 ("vfs: Convert ramfs, shmem, tmpfs, devtmpfs, rootfs to use the new mount API")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/shmem.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index ba40fac908c5..32aa9d46b87c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -413,7 +413,7 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 
 static int shmem_huge __read_mostly;
 
-#if defined(CONFIG_SYSFS) || defined(CONFIG_TMPFS)
+#if defined(CONFIG_SYSFS)
 static int shmem_parse_huge(const char *str)
 {
 	if (!strcmp(str, "never"))
@@ -430,7 +430,9 @@ static int shmem_parse_huge(const char *str)
 		return SHMEM_HUGE_FORCE;
 	return -EINVAL;
 }
+#endif
 
+#if defined(CONFIG_SYSFS) || defined(CONFIG_TMPFS)
 static const char *shmem_format_huge(int huge)
 {
 	switch (huge) {
-- 
2.20.0

