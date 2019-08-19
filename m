Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C573DC3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:14:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A5A020843
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 13:14:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ouW48h7H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A5A020843
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20C356B0008; Mon, 19 Aug 2019 09:14:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BD8A6B000A; Mon, 19 Aug 2019 09:14:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D2E16B000C; Mon, 19 Aug 2019 09:14:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0053.hostedemail.com [216.40.44.53])
	by kanga.kvack.org (Postfix) with ESMTP id E01FC6B0008
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 09:14:52 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 847123CEF
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:14:52 +0000 (UTC)
X-FDA: 75839222424.23.flag22_479e948b8701c
X-HE-Tag: flag22_479e948b8701c
X-Filterd-Recvd-Size: 5079
Received: from mail-yw1-f73.google.com (mail-yw1-f73.google.com [209.85.161.73])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 13:14:52 +0000 (UTC)
Received: by mail-yw1-f73.google.com with SMTP id l22so3046347ywa.8
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 06:14:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=oNoDUi1hsmNzzodU0R6ojKZvjIC3JQAmU+NA/+7Uaps=;
        b=ouW48h7HGbpdNdCReL1nk2+dvRXfxgklc1nbCP+Q9JJOIGCVyS3fqahBo1S2d8316M
         OZxTJFVIgB1yHxwjdFezXxDGLz9wKstEmjea5fp8x0waRP2D4PtWy/8cEd94ITbDy+AB
         ohMM7RCZVEao1hTKwgkNZsuSnXQ52npfKzrCB8hagDJHWUZyqV94tepmovte0/cp0h4L
         SvPXvaVH6Kvmqsu415sDgkqDdnh0pnuy5EbzAZl/JGrx9UiwjWAucl5+kBCOYUeFDUvr
         0QJUC5x7f/83eUXVQvxdzpHaeshvsSjN84YEl5sN0EdVOxlMEIgfFzUzZo6IFB3/q633
         zoEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:message-id:mime-version:subject:from:to:cc;
        bh=oNoDUi1hsmNzzodU0R6ojKZvjIC3JQAmU+NA/+7Uaps=;
        b=gbLeBuKJk0kEKWI+sDYXdcdIjbw1OF1Yg8xP5kov+3BrrySdSbloQeF9dF9synZics
         eD4CKayoAErolq1DHkcQDB9KuaafKgBeCHkPRXLJmc5LJPtk7vcim5AwHuLyxVcuMUsQ
         Ac6UEDV9xB2PyVd8zCkPvNK/w1ieDeCNVFcmyAPRxoJEWFn6BCqDM5STiQtmH7KQD1BC
         /7jnjEHqAR6no49saCnCGxNyH7h7KJDUWC9p/ZpxbDN7IXgj7dTMraiQ2EPiLPb5N559
         rMzql/87+8BlrJ6lc6hYhga2r5hgcLe88co7qyFgNPnyTI1iQYoowVNc6N9098UarKjC
         G06A==
X-Gm-Message-State: APjAAAUwQHq3QeyY99ENPzqf9eWONa4H2WGXk7My+KkXNIMFFDiJPwnh
	Ft1gr7t/jDtizbfFps5sVT2mJq2sG3eg951n
X-Google-Smtp-Source: APXvYqwFX5U5jD7RsGf0G3vM/9ehnT3AiWsZaEFsyMkoc/hovIoyUTjRlHyWf2f4E//56cQouSUIEdq8hx31clIz
X-Received: by 2002:a81:6c85:: with SMTP id h127mr16796224ywc.111.1566220491100;
 Mon, 19 Aug 2019 06:14:51 -0700 (PDT)
Date: Mon, 19 Aug 2019 15:14:42 +0200
Message-Id: <00eb8ba84205c59cac01b1b47615116a461c302c.1566220355.git.andreyknvl@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [PATCH ARM] selftests, arm64: fix uninitialized symbol in tags_test.c
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, Will Deacon <will.deacon@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Dan Carpenter <dan.carpenter@oracle.com>, Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix tagged_ptr not being initialized when TBI is not enabled.

Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 tools/testing/selftests/arm64/tags_test.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/arm64/tags_test.c b/tools/testing/selftests/arm64/tags_test.c
index 22a1b266e373..5701163460ef 100644
--- a/tools/testing/selftests/arm64/tags_test.c
+++ b/tools/testing/selftests/arm64/tags_test.c
@@ -14,15 +14,17 @@
 int main(void)
 {
 	static int tbi_enabled = 0;
-	struct utsname *ptr, *tagged_ptr;
+	unsigned long tag = 0;
+	struct utsname *ptr;
 	int err;
 
 	if (prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE, 0, 0, 0) == 0)
 		tbi_enabled = 1;
 	ptr = (struct utsname *)malloc(sizeof(*ptr));
 	if (tbi_enabled)
-		tagged_ptr = (struct utsname *)SET_TAG(ptr, 0x42);
-	err = uname(tagged_ptr);
+		tag = 0x42;
+	ptr = (struct utsname *)SET_TAG(ptr, tag);
+	err = uname(ptr);
 	free(ptr);
 
 	return err;
-- 
2.23.0.rc1.153.gdeed80330f-goog


