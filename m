Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0F75C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:54:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F2392075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:54:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N/CagzxO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F2392075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EF068E0101; Fri, 22 Feb 2019 07:53:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 823D88E00FD; Fri, 22 Feb 2019 07:53:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D4FE8E0101; Fri, 22 Feb 2019 07:53:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id F110E8E00FD
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:50 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id p4so286843wmc.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mpZDvMXD49QdxJt8wpvUxUfka//FLmK5Q3bpesHxKPk=;
        b=HC0TADVJ8/pvcYOuyQ3cisSwbfT7LMOxqqsxkWg49pf3f1qV6ZeFvWB4Fx2EYiaJ1B
         gHzUcfnfQy3eo3SQA4bkJRTsDaT8+RCOVa/e1u6MbhvgxawRQpOUzwMkp8L+SDWsZiEE
         obttkHGmrI/xXrylfuMfZBdvX/5G8zinaAZb/vwdFz9Ma9Ap3WuOLwAi1DGVVYtCOG+m
         HCRFZ4T3GbPEMzwdt4M2wtN3xCrTmiiY2bwI/Ez9N+1/a5zqsUx79AZ/d/P7DLxIYa1D
         6R+f+fCy9zCz4p5BY44diSonTZ50dMd2jyxizu/UnznrDwB3LValbE3Loc/+uQvXPpsF
         K3gg==
X-Gm-Message-State: AHQUAuagL7MwU3DyzyZUcbSDz/PmdogXiaQix/W9Inj6uwawb73PIeFw
	y+kR/HKGluUDbuOC5xOl+QEV6ZcUunBqSpHM6w1pOncGIDT0axpBpHyOZ/22wQ51Hj/0UrvHTkX
	VxXyLUaYC3LH36vLrT4V9xUTE3eXY0jugAAe+uCpCppoh6sUvRxEWaEpO9/qUafodiloRgWH0NS
	H4FJtsnF3LUN6jQfA3kx4ux9WTMwu26BVZctr0gdTS3PyuXwJERZLu4zqk1flXeRSUn7EcDbQQr
	3gUJ19W/a0pKrudKxR2P7Zl03yO67no2KDx/AbMmKeInmtKCFtN6jo9cbcwogvLWpJJyi8PjBQW
	X4D2+P/wB9+x6ZOzOCm2iIW7z0aWkgYP62rxSXIGWj836qS75JkyAMOrz53K4Auvimz/ah5yHeM
	5
X-Received: by 2002:adf:eb45:: with SMTP id u5mr2779667wrn.102.1550840030470;
        Fri, 22 Feb 2019 04:53:50 -0800 (PST)
X-Received: by 2002:adf:eb45:: with SMTP id u5mr2779630wrn.102.1550840029655;
        Fri, 22 Feb 2019 04:53:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840029; cv=none;
        d=google.com; s=arc-20160816;
        b=JuRssvnaiKZUSVAgfGHPw7R6g2xS4tQqB5uKNC5Q+VVv21b+hw9wWcnL5foU/I/QI2
         +YIb80gLf+Sv1GxsOBJycU+QCQwgzG0po5IipCpXTZIP9MCB3fheV+DBMfL3tzf/2XgI
         GhyVr5Uzr9CrHRPKoUNpEUqywu2Qs9EMuM7MkJfOgRnVLprXI2vaPZ4ksgkc/k/zOQhi
         4RX/FuqrLP8c4+dNnPxQAxk03ZYcspyy3k3Unxk3S+bzur2M7xYa9chBP7wuPSUV0Bez
         AReaLHqkcuGdR43Emmhi+17J6YUV/DSzBPn911txhBDkz7d4xtR0BD92Y4kcCuHn6GJv
         3d7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=mpZDvMXD49QdxJt8wpvUxUfka//FLmK5Q3bpesHxKPk=;
        b=iqMGjqgcHO37QhiQGOJSoqEnraeM2ys2NJoDAnrf3alScatYaZnSKPrpQIZEWVaDaR
         WEh0aKLlAxTaYbUSTYV37cf89WLxyF7iyplhzuaa+Hx5hLcu9njM8xOS9lnSjuRuYl+o
         zRxjCWWf3TNy/qFVCYzIL3Cl7YhdbwSk6mR9yDsm2P+h+SBicvPUbFZ74gfE18MyoqrT
         Jc9/axvk1hI6DsnjfX7wQD3rsgcaeLVp5YsuufpJfj1RkzjcA8I/0ePeh+FRs8/fZyjA
         EVuWvCaADm0ZHKaRPzAG0us0pP8UVoeZR4P+WyeOAoiHGKm2PoGwUPxVIO9Dha6oNpJx
         bmIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="N/CagzxO";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18sor1098320wrn.45.2019.02.22.04.53.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:49 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="N/CagzxO";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mpZDvMXD49QdxJt8wpvUxUfka//FLmK5Q3bpesHxKPk=;
        b=N/CagzxODuKekdv/276f71hXtTpFv4KVsTM9wpsQCTigrrhdbo1a8DtexWnL0uLpkO
         18omeTVoB8fzJ0j5vhRXb57XZU1dQgAzOHIdQfbKZw9pdxjklam5LDKdghq0pF7kUS4k
         TSktr+912xlWRX6ndEx5vBw3TcYrt2b8W0OjFZ0QWHqpApAu8Ul9v1iLffz1Em/x0Xya
         i4dGp/mgL49JMPe5c8rQczRqypr/Nip2+Eha9JF7UL97GTTb+ns7m5QrUYDBTdT9jbCq
         BDRsMTGNRmV1HHpb/DISeZc2DQhKRnEurBM5elN5TifJa0lXs64tIKkY6Q2oGNBe/Q7A
         j6NQ==
X-Google-Smtp-Source: AHgI3IavQme072cpLVKWYOoRpuCla4tOdeXjezjFtFrbJI9VPdNaXp7MfZlgZAflIs5r0SUzqIri2w==
X-Received: by 2002:adf:fecd:: with SMTP id q13mr2883485wrs.3.1550840029193;
        Fri, 22 Feb 2019 04:53:49 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:48 -0800 (PST)
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
Subject: [PATCH v10 10/12] tracing, arm64: untag user pointers in seq_print_user_ip
Date: Fri, 22 Feb 2019 13:53:22 +0100
Message-Id: <99b59c349ed81d4b204353f54b89f930f01d6ee3.1550839937.git.andreyknvl@google.com>
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

seq_print_user_ip() uses provided user pointers for vma lookups, which
can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/trace/trace_output.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 54373d93e251..7c893328f97b 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -379,7 +379,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 		const struct vm_area_struct *vma;
 
 		down_read(&mm->mmap_sem);
-		vma = find_vma(mm, ip);
+		vma = find_vma(mm, untagged_addr(ip));
 		if (vma) {
 			file = vma->vm_file;
 			vmstart = vma->vm_start;
-- 
2.21.0.rc0.258.g878e2cd30e-goog

