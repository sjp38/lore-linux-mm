Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CBECC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B27FE2239E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="a1Wmmrmp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B27FE2239E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829648E0011; Tue, 23 Jul 2019 13:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B2E18E0002; Tue, 23 Jul 2019 13:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62B828E0011; Tue, 23 Jul 2019 13:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 412CE8E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:40 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id x20so32697060ywg.23
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=JHpRt1iV1Yui2063ArtK5NZw3fPfTbQsXHZ/X8tSe2c=;
        b=VMhlgkCwCEd0wn7niOl8GLDbiq+ku4j1E8o7pKQ6Zx7zpYIEmdFFzer3gklPBJsmxI
         P19ht1un6fTFCRGBzJgfpL3ytoZRfw6O6rFFdNxzYRBJvIkahvrX5tE2PxuppfykSFUo
         K8ZqZGDBj8J60II3IuLWBcnTsrLDRAlipLUY47QIkytVP3e36KATZ6iaBMus8847oPiR
         XF8sJdv3ThpUa+4dVASx//yOVVpS0cmXqTwLi7WZvEvdpOOV7jPPKZVBXLA6ffqzfVnr
         Qwi7Ov4/Dude3/IGWVpuy25bkX6/r80eIPbZ33io2B5lAQW5V2Qp3PLFTteOgodIdQAi
         J/Wg==
X-Gm-Message-State: APjAAAWDWiA4qIZn13sOgs5a9kGPdcxRFQSosZB34gf6tFxr/O0US3pK
	7BZlPbDC9wwBj6eVGD7BFcfZmyZtf0tPCXGnvRyOt1K+Tp4wacB/c3pjbMEFdwcJsW7nnBYi9n8
	c2nNynakDBM/WcOM3I2vRlQxHXHQZDxerRi0OzHAEG+OAVxUlibBUmQ+jvHa7hE05Vw==
X-Received: by 2002:a0d:e6cb:: with SMTP id p194mr47431473ywe.83.1563904780060;
        Tue, 23 Jul 2019 10:59:40 -0700 (PDT)
X-Received: by 2002:a0d:e6cb:: with SMTP id p194mr47431436ywe.83.1563904779083;
        Tue, 23 Jul 2019 10:59:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904779; cv=none;
        d=google.com; s=arc-20160816;
        b=nSbQ4ijddN4oaPIyz8oLG7R/ocjy1qoSYq/BPWXEnOxOS2L8OSiY/vxKx0V4+P8Woj
         C7oYCPz3yK8UDXdRgA4Nl5CjfH01UeN6a9Fd+0xEnNl1/Dc+HUKV0G1SrSyIojqWCr8/
         er9kA5W2SVAQxfdXQMGJGY4xTIrP+rGNeGGTHfd49o/HXmPDAG3r8OuAucaHnBacVfnL
         Yo9rCoB4IMbex1ILGS7hzvSuJvVxnc1rX5HkT07wYBAiZ6GO1vISmKNC1JFG14uV45dm
         e0J7HBpfGhnfd37xL7vccVewNqQxVTy9pnp+ukssj9Bh5xiJOXc9rOgNNZ6O7ZHh6wZu
         eQKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=JHpRt1iV1Yui2063ArtK5NZw3fPfTbQsXHZ/X8tSe2c=;
        b=Yqc46pFTvJ5ZYdKlnmP6sQbsll1q88vNl3UiLZsdG8k4aMSHaQLG2Xe69vrkMCRjpP
         TVHOOka9t48IkuSfhZlRn4ereVWHwWQEAWFvd6T4imR9yBa1fEtiPZlgn5zkztoQVh6U
         4pathoY4QYvHLkcBoSengMBtglEqgl048NL0urtb5YaV+sXeqOp9HhexfuDpZKF0sEud
         AoPa1alWGMoAAdlkUL2lw2iiYGGf2vxIYfU3Qh53nbmDM7480AbT332qkkycFbg2sdjc
         AYMSBz4rexxuNB/4dAuP2e1eWRcKZi9IKvFYp/DnZ615pCgth8xdfBhPKSpJZOgW0lh2
         Emag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=a1Wmmrmp;
       spf=pass (google.com: domain of 3cks3xqokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Cks3XQoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n83sor13176376ywc.6.2019.07.23.10.59.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3cks3xqokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=a1Wmmrmp;
       spf=pass (google.com: domain of 3cks3xqokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Cks3XQoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=JHpRt1iV1Yui2063ArtK5NZw3fPfTbQsXHZ/X8tSe2c=;
        b=a1WmmrmprQZ/rcrg4bnGXYSWuW8VRJo8q/rb7ZTLQKZa1K7I67ixfos045Wbs17Hsc
         4ubobzNkIuAipJMS7ZPZPbwqhOEcQBYGSdXPH8NmRc6nBI3x8EfWx1KUwQ8GdoHMrOVu
         pQBBRoSlOoWQvrJK6Ndgh0M+u5SrtS+Z7XLFtzHXYzmOZcoQreZcqxEy8gyvJGE0ittV
         1ErCh2wjdbyE4mfBH/bts1VkhHwv8KlRuO+94TszgBwo8vjAMA7AFwRnm9ELenbWUlad
         Ar6m6acLtYRugfggNK1CttVM0dqBedFHVAahPgUmqPuarVGgg9aYEhjvXatkNn9RUbXS
         DjvQ==
X-Google-Smtp-Source: APXvYqzQ4z/ZiuFK+6sqRZERC5QgYRRFA4U1Dnbp9V3f1PKQeQRLZSu3TG/nr3g90hvkMvcrT8eNvmOVLDqS9X26
X-Received: by 2002:a0d:d616:: with SMTP id y22mr43437325ywd.365.1563904778592;
 Tue, 23 Jul 2019 10:59:38 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:47 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <c856babeb67195b35603b8d5ba386a2819cec5ff.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 10/15] drm/radeon: untag user pointers in radeon_gem_userptr_ioctl
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

In radeon_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
userspace pointer. The untagged address should be used so that MMU
notifiers for the untagged address get correctly matched up with the right
BO. This funcation also calls radeon_ttm_tt_pin_userptr(), which uses
provided user pointers for vma lookups, which can only by done with
untagged pointers.

This patch untags user pointers in radeon_gem_userptr_ioctl().

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/gpu/drm/radeon/radeon_gem.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
index d8bc5d2dfd61..89353098b627 100644
--- a/drivers/gpu/drm/radeon/radeon_gem.c
+++ b/drivers/gpu/drm/radeon/radeon_gem.c
@@ -296,6 +296,8 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
 	uint32_t handle;
 	int r;
 
+	args->addr = untagged_addr(args->addr);
+
 	if (offset_in_page(args->addr | args->size))
 		return -EINVAL;
 
-- 
2.22.0.709.g102302147b-goog

