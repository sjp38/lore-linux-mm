Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 083F3C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFAA5207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B3gwK58H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFAA5207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B837C8E0100; Fri, 22 Feb 2019 07:53:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A99708E00FD; Fri, 22 Feb 2019 07:53:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FF768E0100; Fri, 22 Feb 2019 07:53:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 233808E00FD
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:49 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h2so977890wre.9
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2tCXxaQ0AcT215cB6TyMBJl5HSukg9TNH5t025IrNLw=;
        b=FE8EHq5EapLmkw71pReu1IWLD8ao0Sg6UW/Luis2uuMZJCXxnXcNHVuwFf77Eqc4bC
         XC1Myp+XZoDFJrn1Sy45jGBhrqrneqtCpY1ziM0TPu9Hz5BC2P3a7SrINNvOxAPhRreC
         o4FPjKJvLuj0cIjhqXuotW9PU2Kr18O66mnN/rXnnA1yfCeZlj/U9o5jm+luFyaOR/K5
         Cd4OVOAOQFfpkhq/p95JrMJtjJs9q6rgTqZy0+hOtlythAc2jKs/WqioisoCXKyVBaB4
         KZWN14ONxBsvmHt8rSqnJq5alapanHpSCBbOv1sdez8w3avbBQ3akMUQJKd+uccLHlBG
         fAaQ==
X-Gm-Message-State: AHQUAuZTk1ZQRSPAo08L46r9WGGtfWweAhQiE9lBnS57OgIXyj+9N/3i
	3McXaAm+/SqUygLTzJQ1buMzq0ZuNWgRI/jbvDmZ/sr+mJHjlqsQoKgDSjyvlPu+EOWPy2vEhn1
	MHisTj+d023PFq21dlUbdV74My5++7VFC8ki560+bTfF7CY1LCUuq6b5z5LQ1ndYO+EwS7QJpqp
	L5sWPQNxL9ilzTPlLdE7M5TWYa965P/ym7DgI+5jLN7A/DK3hYTuU59ZN1B3TVLitjW9arlR0RS
	aqlssORpr99hYD5W8SlMZJHoK0TKwjPMaH1BNdTU67oiJuU2FrIyCm9SiNqaNq+7OvN0ya1f/7t
	uhaPb95LubireNOD9Qm9dGMKkuM/3uBXF3Std8Jk3dQPkXNDmkYVZLAeY/tT+utyuwbHq10/Dxc
	l
X-Received: by 2002:a5d:474f:: with SMTP id o15mr2982018wrs.70.1550840028692;
        Fri, 22 Feb 2019 04:53:48 -0800 (PST)
X-Received: by 2002:a5d:474f:: with SMTP id o15mr2981978wrs.70.1550840027916;
        Fri, 22 Feb 2019 04:53:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840027; cv=none;
        d=google.com; s=arc-20160816;
        b=p3wwXRVR5bh5rX+z5auxWRQW2NaS8ylgyLl7Vq8lCFgTN1E0mxSCuEFRGGoxHBP9Lz
         vCCnkVdoJxyHod80oqhirUc2g2UD1ynXZOKWnEilJ5qZCxiJmudwKjX+HMqXINVnyDau
         FgriJPWqOTc1yWH2EvSvFkQt2WrRIgm+xYAnFGiLkFPmelyEj+1BXR+MS0u29xGFoUAV
         bP96zFunYvyaggSXsiJJetrEVOa67t3ATr1CtDhnCj2YWUwXGEig1GRBiVeIoUzADqMQ
         AvCxfvI9HGQlzOLY8f5Ituobeqsx5QMQpu0e+iCQybiZie4V6OQHyskTJhsybad93rC7
         OunQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=2tCXxaQ0AcT215cB6TyMBJl5HSukg9TNH5t025IrNLw=;
        b=D2f09Q1fQs2fvAWp2Ou1TXK+im377QYAgPcUjr62GmtS/T09aNv53A4efosTC6MtOU
         egSHW+yIA6p6bkDOTJWlwzdJ4Aam/nvzRDPGP7Q9adh7FVArbs652oeKMUGMa5fRoQ3o
         Zyrr0RlRYOveH+90oemHH5od28vIcfkhPSNL0KzAkwuJ1nDd5B7ikHm5kAaMPdRGtLvV
         mKm8+twzOxfVATyfZ6tjYC/J2Z0Yu4V3vpjJwc5tAQ01EhioYz2wJcdtM+iT909aIrLN
         Qdd+38y/6D3F70CUYKvYzFLWwATTncLXhupPLmsyzEva/szfC40F5FandnRz94qNSg+C
         42IA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B3gwK58H;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15sor1090330wrn.3.2019.02.22.04.53.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:47 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B3gwK58H;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=2tCXxaQ0AcT215cB6TyMBJl5HSukg9TNH5t025IrNLw=;
        b=B3gwK58HnJ85CmTL2efZvH+J/Nm20KCnydLNY0dw7gbtvGIUGcldP8npiWTUpDXgKz
         /u11H7eQqGQOsrUx9Bjjx9CGJcxvqjtgzrsVE+c4Cnr2aH4wSMA3cBw28f4m5dvZcDtW
         dE9QsCl+18tkcm6KtqrSMoS1/n9nvYZMf6UFWkly4U8pHmTr2bgB/2tzCG5OvgHPbq1p
         LygIpIzOhXUWhS3SS/cArJu5XyCYKaSFAA2Xlb21EPCN/ry2nFAF1xMDOUEnala+awoK
         ndjVy074STqch02YUSBKRqql7aX75kVTJAVZrchuqsIoYuA52Cu849nBt6+cAxrGpU8H
         43FQ==
X-Google-Smtp-Source: AHgI3IYJ4JqjThJgosMpQUX8CWU96fplWtblPpUxW7NKKKm/ffsucHxns87xgSXmASXlP8q7nFWW4A==
X-Received: by 2002:adf:ed0f:: with SMTP id a15mr2881069wro.249.1550840027447;
        Fri, 22 Feb 2019 04:53:47 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:46 -0800 (PST)
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
Subject: [PATCH v10 09/12] kernel, arm64: untag user pointers in prctl_set_mm*
Date: Fri, 22 Feb 2019 13:53:21 +0100
Message-Id: <d6febfc14cf0190f4ccd84fc1bf9bd077a6d6a9f.1550839937.git.andreyknvl@google.com>
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

prctl_set_mm() and prctl_set_mm_map() use provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/sys.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/kernel/sys.c b/kernel/sys.c
index f7eb62eceb24..12910be94b7f 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1992,6 +1992,18 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 	if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
 		return -EFAULT;
 
+	prctl_map->start_code	= untagged_addr(prctl_map.start_code);
+	prctl_map->end_code	= untagged_addr(prctl_map.end_code);
+	prctl_map->start_data	= untagged_addr(prctl_map.start_data);
+	prctl_map->end_data	= untagged_addr(prctl_map.end_data);
+	prctl_map->start_brk	= untagged_addr(prctl_map.start_brk);
+	prctl_map->brk		= untagged_addr(prctl_map.brk);
+	prctl_map->start_stack	= untagged_addr(prctl_map.start_stack);
+	prctl_map->arg_start	= untagged_addr(prctl_map.arg_start);
+	prctl_map->arg_end	= untagged_addr(prctl_map.arg_end);
+	prctl_map->env_start	= untagged_addr(prctl_map.env_start);
+	prctl_map->env_end	= untagged_addr(prctl_map.env_end);
+
 	error = validate_prctl_map(&prctl_map);
 	if (error)
 		return error;
@@ -2105,6 +2117,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
 			      opt != PR_SET_MM_MAP_SIZE)))
 		return -EINVAL;
 
+	addr = untagged_addr(addr);
+
 #ifdef CONFIG_CHECKPOINT_RESTORE
 	if (opt == PR_SET_MM_MAP || opt == PR_SET_MM_MAP_SIZE)
 		return prctl_set_mm_map(opt, (const void __user *)addr, arg4);
-- 
2.21.0.rc0.258.g878e2cd30e-goog

