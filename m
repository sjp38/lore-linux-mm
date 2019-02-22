Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1675C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8010F2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BdeC2+jN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8010F2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FD758E00FE; Fri, 22 Feb 2019 07:53:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 037898E00FD; Fri, 22 Feb 2019 07:53:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC9CF8E00FE; Fri, 22 Feb 2019 07:53:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E2CC8E00FD
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:45 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v24so937474wrd.23
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YCJNq7ywB4uaUqF1MkWtAuFgMYZGYk6wr0hn7fPLDX8=;
        b=gyMrt9R+J75Hrp7rvYx1lB1bfhwIRT/JLnAygAgFUuyENcI4bEYqz4AIj+lJ5Oz4Lh
         fHLedeQ9lMQaGI9g8GhPY5EejcV3KSiSl6opI3A1OmBy/+pSBBWX0QDxVeooAplnPEzz
         IsgVHf5qEZLuuutqgg6U+qFSWmH0lHsauzyJZCLVkNBdL+sbN6mdz1g0GK8/SnH5qLEP
         FNf6NwBcw+i/e4NmzclVD06flBdqGizWkNINxOxwoZ2QeVvNhhLxXaTp3InP+z/lJ7aw
         okITSVfBC/e1v1AGfoMZo4GJpFogzDnJ/0eOUxTe05ybObmSna64vdqTbeEySW6x55jf
         3TIQ==
X-Gm-Message-State: AHQUAuaKovmPxkns0GbvZDRE32eUtuR69Ku5SspCa8dFAp/5aWAZQLcs
	WXcKiwPFky/OjzQ5CuL4AJqBkjXGA3QP4N1TFBnkKN1ptBlTK9Qq5pAOr0RLx352F42Mt6IdI7r
	QZxf+wySJZyOSqx4+Pym/4saEqCwXbiH4ejJ8C6u89F11GkGISOCWIkyjk8juN0MudLXEwxBVKt
	JlsEF8s7DY8T3YkOcEfpo2iHUMl3tarOyIdtoRkn4lpwv/yNTwANMOB/VcCF2SWTYJgHFxDkOvC
	zNBj9EPakcyuX9QUCCUlFSyHPsn6lUd0/mcgNt22dILuJmVKnRXzsAv4uFQ97pZt43WOiIQeyTN
	dH14y+w7rQuyN2Xfqx8iOXlthQnINONJnwi5FK47k4QxDsmjxJ7NBaYt4FKCtMBZefcjPHJCtum
	D
X-Received: by 2002:a1c:e1c4:: with SMTP id y187mr2499680wmg.50.1550840025043;
        Fri, 22 Feb 2019 04:53:45 -0800 (PST)
X-Received: by 2002:a1c:e1c4:: with SMTP id y187mr2499630wmg.50.1550840024202;
        Fri, 22 Feb 2019 04:53:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840024; cv=none;
        d=google.com; s=arc-20160816;
        b=qxNbviZytyC5LmVVCXFLNtU7XtscTAL2Dau271dD+bI3PbUyQAL+TTIa78Gm6cdVs4
         UEaWpoTa88XrWHZHZd6Op0T7OA9Rr0+dmaQOQtOF4ab/OZ+mb5Z/fgRqTc5BdxSMOV2Y
         Cesi6z4FU51QQAQw0ZYVKEOTvHTivpKq0rhQNecV/jiBlKM6KDF0RJBOW8Sh/V6SRT5Q
         r9VwWuX6pjgostC1RKm0OGT6IJJA+4IE0/7c94lfNqTzshJIbecNF4GU0VmOgnt4Ty/v
         Gi5VrlAVAcHGNN3QAPSo8j9zxdTXWI9mDXn/GRbbzDlq4DT9KwSHB7p61r5nDH7oNEqU
         sxBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YCJNq7ywB4uaUqF1MkWtAuFgMYZGYk6wr0hn7fPLDX8=;
        b=IEj/wGoCNOrbZ4OkWZJaR7NwK7WJ8JTRRSJ4FC9I7EnC5JjijwgPfNo2IxzL1HOFwu
         sMBwEEf8cPgCV/YjYZp1ddV/GMyBGGinDR3jGJPJdFnhX+AQYxkPl7FA5/z+h80GcavY
         UA+AGVW5lgZg8kATJxgBV756eNkJCCg1EjASGjgrsxa5YolpU4rcaz4ap5oY3enZBXM2
         1rvu1Af7dvrS6uuLlOxEAFN92dd1cLj+oQ/KuECdr4TqS4fMHe5Dt6JbSvTSeQYhSbA8
         bMzoy4KMaU/rLh3WUNrEOYDrtW4fG24cLfPZoqEP1tE8Y4xmYTmVo0Qmre29gnffYXAz
         NMIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BdeC2+jN;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor1091754wrp.39.2019.02.22.04.53.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:44 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BdeC2+jN;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=YCJNq7ywB4uaUqF1MkWtAuFgMYZGYk6wr0hn7fPLDX8=;
        b=BdeC2+jNB/4V8eMU3JsQLO0s40wh5+ubv8EL/H0OL5QAdcdUFTEdOl5givygFGSytf
         jcZdXVsDWgmBZF47af5N9ErRJWRqDdGFbYzwStmoYfWu3LPhdR15RoinUqaGl4Qjgq0d
         YCeMM+dJno0mPLko6w5cnWPaCxS3AA2Rfd/ZMWou0m13PSErWQBsV6d5R8egW63k1+91
         6M6Xf0kf8IIz0JxRxyv6eb8DSW3uJPeZp30Ea6z0EgQHP8RD6UikV9fQtwyB6NNbFht8
         Y6QmzmWpqBZaGR9Y754fPqzonuZULmj8ckN9DYzx0pIKOjOjbgjMmJB8O+P6iH8eCk5e
         9R2A==
X-Google-Smtp-Source: AHgI3IZgI7h36o877UM1PUQ4BYpfOXhaodse0zlvLXALYRj1MboJwPC5054Yq8NVsgrx2Fr3cstKRw==
X-Received: by 2002:adf:efc4:: with SMTP id i4mr3192098wrp.42.1550840023746;
        Fri, 22 Feb 2019 04:53:43 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:42 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 07/12] fs, arm64: untag user pointers in fs/userfaultfd.c
Date: Fri, 22 Feb 2019 13:53:19 +0100
Message-Id: <8343cd77ca301df15839796f3b446b75ce5ffbbf.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

userfaultfd_register() and userfaultfd_unregister() use provided user
pointers for vma lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/userfaultfd.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..a3b70e0d9756 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1320,6 +1320,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 
+	uffdio_register.range.start =
+		untagged_addr(uffdio_register.range.start);
+
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
 	if (ret)
@@ -1507,6 +1510,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
 		goto out;
 
+	uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
+
 	ret = validate_range(mm, uffdio_unregister.start,
 			     uffdio_unregister.len);
 	if (ret)
-- 
2.21.0.rc0.258.g878e2cd30e-goog

