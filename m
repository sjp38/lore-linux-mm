Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF1A8C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:44:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AD7020679
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:44:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AD7020679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=zte.com.cn
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 222356B000D; Wed, 28 Aug 2019 03:44:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 184D66B000E; Wed, 28 Aug 2019 03:44:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024206B0010; Wed, 28 Aug 2019 03:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id C85826B000D
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:44:35 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7E947824CA36
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:44:35 +0000 (UTC)
X-FDA: 75871049310.20.teeth62_27fec1375784d
X-HE-Tag: teeth62_27fec1375784d
X-Filterd-Recvd-Size: 3234
Received: from mxct.zte.com.cn (mx7.zte.com.cn [202.103.147.169])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:44:34 +0000 (UTC)
Received: from mse-fl2.zte.com.cn (unknown [10.30.14.239])
	by Forcepoint Email with ESMTPS id 244A6ABB5E9B5C8EB589;
	Wed, 28 Aug 2019 15:44:26 +0800 (CST)
Received: from notes_smtp.zte.com.cn (notes_smtp.zte.com.cn [10.30.1.239])
	by mse-fl2.zte.com.cn with ESMTP id x7S7glHe066154;
	Wed, 28 Aug 2019 15:42:47 +0800 (GMT-8)
	(envelope-from wang.yi59@zte.com.cn)
Received: from fox-host8.localdomain ([10.74.120.8])
          by szsmtp06.zte.com.cn (Lotus Domino Release 8.5.3FP6)
          with ESMTP id 2019082815430719-3232524 ;
          Wed, 28 Aug 2019 15:43:07 +0800 
From: Yi Wang <wang.yi59@zte.com.cn>
To: akpm@linux-foundation.org
Cc: keescook@chromium.org, dan.j.williams@intel.com, wang.yi59@zte.com.cn,
        cai@lca.pw, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        osalvador@suse.de, mhocko@suse.com, rppt@linux.ibm.com,
        david@redhat.com, richardw.yang@linux.intel.com,
        xue.zhihong@zte.com.cn, up2wing@gmail.com, wang.liang82@zte.com.cn
Subject: [PATCH] mm: fix -Wmissing-prototypes warnings
Date: Wed, 28 Aug 2019 15:42:41 +0800
Message-Id: <1566978161-7293-1-git-send-email-wang.yi59@zte.com.cn>
X-Mailer: git-send-email 1.8.3.1
MIME-Version: 1.0
X-MIMETrack: Itemize by SMTP Server on SZSMTP06/server/zte_ltd(Release 8.5.3FP6|November
 21, 2013) at 2019-08-28 15:43:07,
	Serialize by Router on notes_smtp/zte_ltd(Release 9.0.1FP7|August  17, 2016) at
 2019-08-28 15:42:49
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-MAIL:mse-fl2.zte.com.cn x7S7glHe066154
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We get two warnings when build kernel W=3D1:
mm/shuffle.c:36:12: warning: no previous prototype for =E2=80=98shuffle=5Fs=
how=E2=80=99
[-Wmissing-prototypes]
mm/sparse.c:220:6: warning: no previous prototype for
=E2=80=98subsection=5Fmask=5Fset=E2=80=99 [-Wmissing-prototypes]

Make the function static to fix this.

Signed-off-by: Yi Wang <wang.yi59@zte.com.cn>
---
 mm/shuffle.c | 2 +-
 mm/sparse.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce1248..b3fe97f 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -33,7 +33,7 @@ =5F=5Fmeminit void page=5Falloc=5Fshuffle(enum mm=5Fshuff=
le=5Fctl ctl)
 }
=20
 static bool shuffle=5Fparam;
-extern int shuffle=5Fshow(char *buffer, const struct kernel=5Fparam *kp)
+static int shuffle=5Fshow(char *buffer, const struct kernel=5Fparam *kp)
 {
 	return sprintf(buffer, "%c\n", test=5Fbit(SHUFFLE=5FENABLE, &shuffle=5Fst=
ate)
 			? 'Y' : 'N');
diff --git a/mm/sparse.c b/mm/sparse.c
index 72f010d..49006dd 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -217,7 +217,7 @@ static inline unsigned long first=5Fpresent=5Fsection=
=5Fnr(void)
 	return next=5Fpresent=5Fsection=5Fnr(-1);
 }
=20
-void subsection=5Fmask=5Fset(unsigned long *map, unsigned long pfn,
+static void subsection=5Fmask=5Fset(unsigned long *map, unsigned long pfn,
 		unsigned long nr=5Fpages)
 {
 	int idx =3D subsection=5Fmap=5Findex(pfn);
--=20
1.8.3.1


