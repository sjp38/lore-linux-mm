Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB9F2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CE132184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:52:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sexMIu8a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CE132184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49E786B0271; Wed, 20 Mar 2019 10:52:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42FFE6B0273; Wed, 20 Mar 2019 10:52:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2534B6B0272; Wed, 20 Mar 2019 10:52:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF6786B0270
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:52:37 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id x185so3430892ywd.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:52:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=JYfYaqFkvasJC562WHpti4tYqqXwAjMl9KNYEduKdaE=;
        b=InXhwHNB1PwZoFY11lg4e0J1CKF7W4wh3jnhuyjRe5nR7VQsm1viUUzFhDHTE/Zq4Z
         TNLgiojUZq7pehhTMJFli03Es+9u/NdZJNqEz63k7Jv3OQ2tmc9nCmmbd3hoqmRQnSx/
         MW1aMwTkbyCp6f3++tIe+fHm7SZIlDzNMVLdmCAp2LUxFZ6ah+lvvPxQzQEm8M9r+H2b
         PtSxYJ8gNmTzOplhbQLdbslXf4+rZTzYyM/WWy5UxZvbXzDxVzkgDZIuv7jj79g8265H
         9Ynt+ZywW1Q67D/ephPFUAINZIQ8TkGp47UKjgB5reZBn/aNzMzIJwj0ezCibFgR7MAa
         KUTQ==
X-Gm-Message-State: APjAAAX65/1Fx4FfaZAMI5JZyvnjqIqmVQk6eB3bGRif3yPYbINDzapI
	YaJVYrxuW76NkfS3p9ZR39kRVRF0yBpkUoPYxebNba0yRxiajR/NTqEDSHlI2+Ghn94BlhSP1LX
	5DvW0gWlLI4x18F0zdJybPkAKa22moVsuZc1IAwD+sExzOS2BxRPdLfr7ejrgxSSR+w==
X-Received: by 2002:a25:ea02:: with SMTP id p2mr7284814ybd.41.1553093557730;
        Wed, 20 Mar 2019 07:52:37 -0700 (PDT)
X-Received: by 2002:a25:ea02:: with SMTP id p2mr7284754ybd.41.1553093556781;
        Wed, 20 Mar 2019 07:52:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093556; cv=none;
        d=google.com; s=arc-20160816;
        b=HH4K+13dLZ2GQas3t3wwKwsBXjP787V82yH6WUW01sC5zYd9M6X8znXKFlwIN9YHfr
         ZT+B/+pin3UxLMjraTBY1bOln4QbEKAzg3IhsdgwGKUC8UcoFz4fl1sZCSn8C7kZn2Su
         uurKx2QJCbq8RTYnt7HeJrmtkpZ30mzJ3Sd9rFUsNlOu+fBmThaSgenFukqjLanpnexl
         RdXQmN7/MtLdlS6z2x4Uzm2H+wPgpBQcdI2rdqyG3xsBivksQuxgrKSPxk+ndgWbQuTs
         DBW1ManBTEoHHQ2YlGTf7p37uKqtNUzGu76XjUz7oFOyRgqeNuXQJYSe3fanFl9QobIf
         7YVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=JYfYaqFkvasJC562WHpti4tYqqXwAjMl9KNYEduKdaE=;
        b=OaOJA6H9v28gCvTpXMmIaDtYMzyxAdhDG8zjVU3MdFjsVBVPROTzIsS8B3Z3NMr7c+
         cogD2QMhHuqx8hSxTJffcQezBjtmwl76N5TmjG9jrJhgIBsX5lCdamknplfqoMrYJAYl
         uijPlk+6lBC3iurnizX2tP7Hb2ZWZPn5xv4rvj2cnGUYDF0CosoTexw7IXqiOD2bFUjd
         zpWKJLQ8ppI4b9xSs6A9ejbZF3Loz0BpX+UuCrmf2RyyfJxYAH1RQmBf+izpOwZ+Ygtt
         YiSMcpz4Mv8RcAjVbKjINpcIAJoX7MARdQ1SjBEbgOuNbhC0vcYSCjMkmmhV+Km9P7ZR
         HNzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sexMIu8a;
       spf=pass (google.com: domain of 3tfosxaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tFOSXAoKCI8t6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i23sor1028257yba.65.2019.03.20.07.52.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:52:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3tfosxaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sexMIu8a;
       spf=pass (google.com: domain of 3tfosxaokci8t6waxh36e4z77z4x.v75416dg-553etv3.7az@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3tFOSXAoKCI8t6wAxH36E4z77z4x.v75416DG-553Etv3.7Az@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=JYfYaqFkvasJC562WHpti4tYqqXwAjMl9KNYEduKdaE=;
        b=sexMIu8avs3PQT75uBvPTQ7a6BwfzDpDtEim0BHpT2lZIdVCSQQNJCOv1y+KBVjuwz
         NX0TZsiakkaHgGM438rpKshO2lygtlHGBjF9I7HIZlISq6IjvdJBMN68/khgYyArgEAc
         8tbatLWytzPpO7bRWCVSIFqMId8s/P66Z59No3RuANZfIft4UrNO78pUbAaCEl8oBE2Q
         qNCkyYahb1b1Pv7Y/SBLJD0dj0RxnH2fWpp5qHUGdBZK+/bAoxPvBHDVj/4wKQ82tyl8
         DVhiys3Wu1xJZ38zAN40H2K69ZFtxYiDzY02fAJ60bAOEsljjjp1FIjebecLuWwY+E7M
         Zatw==
X-Google-Smtp-Source: APXvYqz/OFC1PuPZodVHMFKw9kUzVJMyrdAYISJ9xGPWIvonfiJf4upSDw3KUidiP9gNNGgKCiqyzVAdZse9Ion/
X-Received: by 2002:a25:bb8c:: with SMTP id y12mr2095179ybg.89.1553093556448;
 Wed, 20 Mar 2019 07:52:36 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:30 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in mlx4_get_umem_mr
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 395379a480cb..9a35ed2c6a6f 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 	 * again
 	 */
 	if (!ib_access_writable(access_flags)) {
+		unsigned long untagged_start = untagged_addr(start);
 		struct vm_area_struct *vma;
 
 		down_read(&current->mm->mmap_sem);
@@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 		 * cover the memory, but for now it requires a single vma to
 		 * entirely cover the MR to support RO mappings.
 		 */
-		vma = find_vma(current->mm, start);
-		if (vma && vma->vm_end >= start + length &&
-		    vma->vm_start <= start) {
+		vma = find_vma(current->mm, untagged_start);
+		if (vma && vma->vm_end >= untagged_start + length &&
+		    vma->vm_start <= untagged_start) {
 			if (vma->vm_flags & VM_WRITE)
 				access_flags |= IB_ACCESS_LOCAL_WRITE;
 		} else {
-- 
2.21.0.225.g810b269d1ac-goog

