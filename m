Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04A7DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAA772070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bOHZq9Gt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAA772070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E3588E00D4; Fri, 22 Feb 2019 07:53:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 176C28E00FD; Fri, 22 Feb 2019 07:53:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E488A8E00D4; Fri, 22 Feb 2019 07:53:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8377E8E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:43 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e14so951702wrt.12
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QRzSxiJgMYZtPmoiWjDl90NjyZgMYTYzeKBtn1CA2K4=;
        b=rNQw9ZUUPy8FB7cDPty2EO6fvfZ+ieLMA2bOPoUDw3r6Nk/c3IaHI26Oba2HTiBsFY
         msS+E/bO1lPnb8IuMfjskdN+MzPjPKVwOQdGdOTfQd+IfTVA6jgoZ+yOZf5KUDIZYAUj
         LO2F+5Kc7qvJj+WL9+8W2pz5L5lTWHkrGqWb/WyapeijPvV61azMK6wXd08k61vyjYhw
         VxZ/F13YLtoeXI6VJ9OxBr1issEJUkd1VrWd7vMV+biIxwduF4ggO1jpdvkIz+msFqF1
         7CN88P0UnRwmWEvG641j0+NkKVgEw7Sw/t/E8U2OuICZywGosccMa/i0vvyn+E6huYml
         AXeg==
X-Gm-Message-State: AHQUAuacW3FOq7b6+x3Vf7ira01Ucf7e8tQqR6BeDAdBsqhhv6tah0uT
	+VPfJkP+uU2fv1suLz0GadNPgNbDIES9NjPnBm5gzEGCFqkgR/BOEdf1g4vr4dG+ehZ2WJg3Thl
	rYLdGYLzb+92F5UiLgoGQcPjFGFr93QP67/780soP0ayHL4Ci6vC0XhezaUGxDlXSnmZZfn/Rmp
	CN2IuYOevfA4sw+m1BRoT4kH2P9oQzIusZxCaktVehQ/PaK9Zu/tI3da5dkFUC8/DVMpa836s8F
	KvQOn0BznA5LaJck8Ps7TqRLRlRw8izUQOVfVgQODFk26FXs/i2foo+FQ4w7aLyNzrin8ekmgip
	7YDgsUhgOv5Aaim9JtNKMEVLThx2l+mSXRjNv4/S3VHgNrE1ED8ycyV2xds675oZ7Ws8CtPvF4h
	S
X-Received: by 2002:adf:e641:: with SMTP id b1mr2796993wrn.213.1550840023068;
        Fri, 22 Feb 2019 04:53:43 -0800 (PST)
X-Received: by 2002:adf:e641:: with SMTP id b1mr2796954wrn.213.1550840022289;
        Fri, 22 Feb 2019 04:53:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840022; cv=none;
        d=google.com; s=arc-20160816;
        b=QWMNDVhzdd6hpg0uU1SToQInvibZXGVe2EWa8kmBbEMdAVBwfywRQRjsV6DSnZ08VF
         If1QjPde+mzMYYvfn5JWWf3yk5o1mVV9IT2zf/IM9vjEAqNNPbaFTESqKY3sbvr+ptmT
         aXuWCJJbfxJj4P6oWzrUPlaH1alaPvnQH6VggyP2UY/2VmCLuhtQLbNBomrS3z9XLYg7
         XLm+oWE09a+VGpDwq1bjcY68qTys8tffMiOFc/kdKSqXhWQCyRN36qRa7eIYfWCXBvle
         qGFjW3UMtC5UiYi48J6dqOpw101VfgKECV/S1QhbnOJpsuFPmhb7VyEKsSiBekgzPHEZ
         LIlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QRzSxiJgMYZtPmoiWjDl90NjyZgMYTYzeKBtn1CA2K4=;
        b=LNDTyFt9yCpaodLlPM55gR9D+cAb1OkpW5zx6VANJR0oNdjWEVx47U6cWELG28ac4f
         byJobznTGczgGZND3DB+wNX7aslpNBzh0hj66yhJ/uAWJo5g8yI5bRxQAs3z7Y0UA0Z/
         0ewC+BoVMKCpyi20taIHw+aT/8WOB4ysmhdNJvw1QbXkLhb4rgtFEtHYBCXx5ybeh/SA
         W0gebyGWLsrmVIrJSRx94Pz6za590LpGDfLOQS9WJKhCjN4XA2PRxmvXuEevFizpXjAH
         4erbaxHfKYPo+iKqnts/70Ljc6oiBQn+DrI1GHD2pM8XidAbadN8iy0o3OEYJBUR424O
         YpvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bOHZq9Gt;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b14sor1109798wrx.20.2019.02.22.04.53.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:42 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bOHZq9Gt;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QRzSxiJgMYZtPmoiWjDl90NjyZgMYTYzeKBtn1CA2K4=;
        b=bOHZq9GtneVcqI+7dx1dPlGbKg1NqyMwC/3dQj65R9b+AaL1dEw6WnsEFnvda6QlbD
         lx5q7BJ+HMum/sxb5KUmNx4YqHmnliyifP16MSQibp7C2IHgTBNe1hU9pCqsXLkuat1c
         znpbV/DdU4KpgxO4goYtaVe+u2TyXP6kbQ1RoQds32uwFxEU5JLU4SpkXRt6LADYtjAl
         WI1hDIyHVRaaElIfgQVsUPN+J6MsWMExP4yrdvC2wBzICHHXVDfMEKh4sCD1RwZwqDI3
         3IZIK/md1m1LDI9VJmKIDCuhLJSumlID2vVjptcouY1GMsQmr4PDIVNhj6rbpSyQdU/5
         NOjw==
X-Google-Smtp-Source: AHgI3IY2qC70XZTghQybUySJZNUvHOQ7jsxQuTtoFLsrp3D/CO4zCTUsA3Qs8Io1jJiy1nb1Hyjy/g==
X-Received: by 2002:adf:822d:: with SMTP id 42mr2852354wrb.63.1550840021805;
        Fri, 22 Feb 2019 04:53:41 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:40 -0800 (PST)
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
Subject: [PATCH v10 06/12] fs, arm64: untag user pointers in copy_mount_options
Date: Fri, 22 Feb 2019 13:53:18 +0100
Message-Id: <a958e202cdbe6e1bac8a37b7f3d9881d1b22993d.1550839937.git.andreyknvl@google.com>
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

In copy_mount_options a user address is being subtracted from TASK_SIZE.
If the address is lower than TASK_SIZE, the size is calculated to not
allow the exact_copy_from_user() call to cross TASK_SIZE boundary.
However if the address is tagged, then the size will be calculated
incorrectly.

Untag the address before subtracting.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 fs/namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index a677b59efd74..d4b7adef9204 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2730,7 +2730,7 @@ void *copy_mount_options(const void __user * data)
 	 * the remainder of the page.
 	 */
 	/* copy_from_user cannot cross TASK_SIZE ! */
-	size = TASK_SIZE - (unsigned long)data;
+	size = TASK_SIZE - (unsigned long)untagged_addr(data);
 	if (size > PAGE_SIZE)
 		size = PAGE_SIZE;
 
-- 
2.21.0.rc0.258.g878e2cd30e-goog

