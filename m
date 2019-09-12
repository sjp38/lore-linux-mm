Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47BD8C5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:29:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFB7C2087E
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 00:29:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tp+vOykV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFB7C2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 433FA6B028C; Wed, 11 Sep 2019 20:29:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E4426B028D; Wed, 11 Sep 2019 20:29:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23AFE6B028E; Wed, 11 Sep 2019 20:29:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id EE8526B028C
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:29:38 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5765F181AC9B4
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:29:38 +0000 (UTC)
X-FDA: 75924385236.27.chair86_19e5d01cbf229
X-HE-Tag: chair86_19e5d01cbf229
X-Filterd-Recvd-Size: 3737
Received: from mail-qk1-f201.google.com (mail-qk1-f201.google.com [209.85.222.201])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 00:29:37 +0000 (UTC)
Received: by mail-qk1-f201.google.com with SMTP id u17so15317055qkj.7
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:29:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=aQObBnsoF37hTK58s3QRsq2XDnpF8nVsAPwHxvDTqp4=;
        b=tp+vOykVFb6wUsjvQv2rrq40mey4jC2MVuUOo62FVit7XzEuaaCrt0Aliep49jaMiY
         XbUwG8uuq24QHYFR1pJXCGLPlk8YErtCXtbkDMHqwebZu9qAnRnSI/g0XfTBOt0PWM5z
         +I1bY29tI3TZKsWz3SvhpAV9F6AiGL9n/hfy/Px34sAcEY7+oQGL2CAHQLWdf+tIglJe
         W3yG6rm1gP6NFBf3dIxi5GmhqJaznQb/QPwy8hRpuMgN4CeDrRfdsP0q/N+e/Gt9Y2Hh
         YepnosVfNG9Kn5Z5M9n1US8q6U8NgabAvnJug85mkUCVYj4mLlaILu8iJr55zzhPg34s
         hzIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=aQObBnsoF37hTK58s3QRsq2XDnpF8nVsAPwHxvDTqp4=;
        b=sQu9bJ0SM83Sq+MhnFUOB21Ax0tvPNb9Ni1Ub1xsu8Yq6J6pIw/De1qZGIXchteF/b
         goJKWfGMlk8YIuKL3+q/C5SZFcE51H/W9HkxKSyLeKJnVt889LyFr8qWhGWJz7gXqTZ3
         Xx98YxSoxYGs3fF5dnCIA0Qbvgio9hXH1gSKRunhD3fvDkeOx72KgLatSe1eJSqvE2GP
         2wZilM8AJvw5Qn+pZ4D2BT4//peGpRA3an7zBdJa51aFXovo+RSVmthj0UPWh/7wsfBa
         vNWNgrTrHd+3Rktac5GjmKsPzYs1UEdvy05VM9YpR9OYDMHO4+3xnmg9jZnkOTWqC6C2
         tOvw==
X-Gm-Message-State: APjAAAVu87VtBwmHAwmV+imBZTgFe6LrpOV+cNcrHTimEcEEol2INLyv
	+xsnf1zBdWKOE0uJndeSviSZuxmC9Ew=
X-Google-Smtp-Source: APXvYqzK80GPgtRHqvxLYSknsuTpGxTEnT/qyaOOSlta3kEOoLG8zvl4/XdyIzaKcqVWNpZnMQh96oPAaU8=
X-Received: by 2002:ac8:678f:: with SMTP id b15mr37229590qtp.293.1568248177173;
 Wed, 11 Sep 2019 17:29:37 -0700 (PDT)
Date: Wed, 11 Sep 2019 18:29:29 -0600
In-Reply-To: <20190912002929.78873-1-yuzhao@google.com>
Message-Id: <20190912002929.78873-3-yuzhao@google.com>
Mime-Version: 1.0
References: <20190911071331.770ecddff6a085330bf2b5f2@linux-foundation.org> <20190912002929.78873-1-yuzhao@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH 3/3] mm: lock slub page when listing objects
From: Yu Zhao <yuzhao@google.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Though I have no idea what the side effect of a race would be,
apparently we want to prevent the free list from being changed
while debugging objects in general.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/slub.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index f28072c9f2ce..2734a092bbff 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4594,10 +4594,14 @@ static void process_slab(struct loc_track *t, struct kmem_cache *s,
 	void *addr = page_address(page);
 	void *p;
 
+	slab_lock(page);
+
 	get_map(s, page, map);
 	for_each_object(p, s, addr, page->objects)
 		if (!test_bit(slab_index(p, s, addr), map))
 			add_location(t, s, get_track(s, p, alloc));
+
+	slab_unlock(page);
 }
 
 static int list_locations(struct kmem_cache *s, char *buf,
-- 
2.23.0.162.g0b9fbb3734-goog


