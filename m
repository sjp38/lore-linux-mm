Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFE7BC76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEF7D2239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uWaCwrDk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEF7D2239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6057F8E0010; Tue, 23 Jul 2019 13:59:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BA6D8E0002; Tue, 23 Jul 2019 13:59:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CD968E0010; Tue, 23 Jul 2019 13:59:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8728E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:39 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l16so32413217qtq.16
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=bNeVrTrPvpjyJWHVtXYqgQlj6F1/0IzkZ0bc3aEFST0=;
        b=HMh1vdF0jHcMrh5XLeZeiKYktf+hgRwMYmxYAzFFNwwxSZeGnJm40CnuiGdCgGDzL9
         PXRFXHizS5HaRYeH6Viw2pOHMCf4AlRfhTmJXbkrLIyzKBKt4AYkAADVXPoKnuyXtB9n
         WwesP31ZUvPiS5lSPuEa2R/lP1ZK+olR0ZpqXt3NAv4q9bqilskfzbe+aOypRWhyEXwA
         /iM2s8r4LpNxxRbUmxZLsssvgXvm2YVtpDx3qmAInz4KWbvqrfKNkJ0rsop7oQsagt5J
         9GazzCbFlK2IL9Y5jIooZIuo5XaUl7UzjdAWnlXmM9K7jzyp6GjuqjlsRg5xHhZSVzF+
         HYcA==
X-Gm-Message-State: APjAAAW7bEnlug6Qcc3UrWGpijkfMQoR8ZpUwuJKNxfVedoVwadL3gZZ
	Hxff16hT4qAXd9/1hqQHPAWrzXTeDKrh7wqAMblKzOa93U55jjKyaVbozjLtKe91V7rTOSFAvON
	qK92P+h2ZvvqXQASTRmr8K/xx/1xcz9FM08XOj14mbRIRaZHMYugH9pd3qag2+FggLg==
X-Received: by 2002:a05:6214:3f0:: with SMTP id cf16mr55329580qvb.211.1563904778937;
        Tue, 23 Jul 2019 10:59:38 -0700 (PDT)
X-Received: by 2002:a05:6214:3f0:: with SMTP id cf16mr55329537qvb.211.1563904775923;
        Tue, 23 Jul 2019 10:59:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904775; cv=none;
        d=google.com; s=arc-20160816;
        b=OxBOB07l3F1Yexg4XRbuhvMQMr95YWCYMq9kuRcqX5x9HOQ7W3HjEoBGaOhprwtLXp
         +loN6SbEqie2WaBNe5MCNPX4HteW9r5B/X95+bBsW3ZWqNnUqrq40Z41lw9Gw3M2Sver
         gSH+f97Nxz7AofteS3Szbg5hWtAD3JupRmup93pZNf/DbKfyxfx1/H0NkYA0fEJGC2Yc
         2iEIdKUQ7B/w96B7li+WdrCJfqbmUmSLSI/qfpuGZKwH3MU8OUlA7eFihjqe5Nms23mD
         V9WLrbJhJ8WC+b+Pc63ELlhpK4ufvRa16E6sA0Pi8ev95tOey730VV/3kuhS8C4jYvpO
         7/MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=bNeVrTrPvpjyJWHVtXYqgQlj6F1/0IzkZ0bc3aEFST0=;
        b=Yy4r+5mIbfo1nOySPyquxbb5Bi+Qd0sITHcgjA26tXkqZqvdhwIee7f3YGYYHrimRF
         7wFxG+emj6ZUyGI5q8kp6EUG3ls5X0owAErIofChXgWaiOfId65jfJXNnFwAiu63WibV
         W2iQuzqNH8RZ5U7MCVALm/2PO7OxnpTXFkHhJD4UC+nGkN3dxijOSLgfU8fRxFNhbJah
         D8mbUBUVvSzPr/VTXe9UJ/367SqV6U1H8wpneA6UyjQdJjTmxOBNmvfnCfufP8k+gKsI
         vYm2gZz/ACwshAmNl5CTURx/hnbrim6UO5CjC+I6F+XbJQLHYSAbfcmUoDuD0pe1CNtw
         zyBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uWaCwrDk;
       spf=pass (google.com: domain of 3b0s3xqokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3B0s3XQoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j8sor25114521qkl.7.2019.07.23.10.59.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3b0s3xqokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=uWaCwrDk;
       spf=pass (google.com: domain of 3b0s3xqokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3B0s3XQoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=bNeVrTrPvpjyJWHVtXYqgQlj6F1/0IzkZ0bc3aEFST0=;
        b=uWaCwrDkBN5GRSLhaw7WQwMKcK3AhPqO/fzElVN3JcPy98UFLj7JeXsg8P+SLlr/8N
         uTaOa6VggUuncDHcvq/dm+VjbWoXQVCEMVj3yqEv0lzhkp6ZqhxIJZIXWJox0QqwZPpw
         oblQlXNCYt4tHVrvlJypYdteLVvehIkVLfAlFHjgdjHvnPpCAD6GJOEurxmklM0IOqwa
         r3we5GB8/FJKwWzwzqUCJtO6E9+uXUbwxjMkihzlNrMKNzLhjZggf+0ZB/LMAafHfS91
         EJUlnCmBt8+isj3aFtdbAWI7Fy268Gzi52Ek2+IZaH/c0AJ5vAsChMY+9qCOx6dYD5bK
         14lw==
X-Google-Smtp-Source: APXvYqyRt/sslYOExeWvOFH4KfKnKxW+V8w8qG436u1Li2H+fm4BIS46hHRf2O8j3VSTAztC1lSBD2N1vfHNfs72
X-Received: by 2002:a05:620a:522:: with SMTP id h2mr54247961qkh.329.1563904775319;
 Tue, 23 Jul 2019 10:59:35 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:46 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <d684e1df08f2ecb6bc292e222b64fa9efbc26e69.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 09/15] drm/amdgpu: untag user pointers
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

In amdgpu_gem_userptr_ioctl() and amdgpu_amdkfd_gpuvm.c/init_user_pages()
an MMU notifier is set up with a (tagged) userspace pointer. The untagged
address should be used so that MMU notifiers for the untagged address get
correctly matched up with the right BO. This patch untag user pointers in
amdgpu_gem_userptr_ioctl() for the GEM case and in amdgpu_amdkfd_gpuvm_
alloc_memory_of_gpu() for the KFD case. This also makes sure that an
untagged pointer is passed to amdgpu_ttm_tt_get_user_pages(), which uses
it for vma lookups.

Reviewed-by: Kees Cook <keescook@chromium.org>
Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c | 2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
index 1d3ee9c42f7e..00468ebf8b76 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
@@ -1103,7 +1103,7 @@ int amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu(
 		alloc_flags = 0;
 		if (!offset || !*offset)
 			return -EINVAL;
-		user_addr = *offset;
+		user_addr = untagged_addr(*offset);
 	} else if (flags & (ALLOC_MEM_FLAGS_DOORBELL |
 			ALLOC_MEM_FLAGS_MMIO_REMAP)) {
 		domain = AMDGPU_GEM_DOMAIN_GTT;
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
index 939f8305511b..d7855842fd51 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
@@ -291,6 +291,8 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	uint32_t handle;
 	int r;
 
+	args->addr = untagged_addr(args->addr);
+
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
 
-- 
2.22.0.709.g102302147b-goog

