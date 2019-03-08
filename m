Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03B54C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCA3E20857
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:43:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ddj5LQyj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCA3E20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E8D28E0005; Fri,  8 Mar 2019 13:43:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C9578E0002; Fri,  8 Mar 2019 13:43:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D8A88E0005; Fri,  8 Mar 2019 13:43:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DEB638E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:43:26 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id e5so21126136pgc.16
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:43:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=bO9Ut6bvYRKsfb9hG438t2Q8GfNMLAbUhphxvMlnr+Y=;
        b=P2wxtCO5fRna/7QZI9e3fgkWF1yHR01hPejk2OolORw1i5loCVinK0KKY6v2at+F0z
         IUgZgq/4F8tfjVJvdJZ0bmTISVYobkM+GwoFEApK+jrj7zssCvDf6t8f+TjQOgcDOY1j
         0m4l3/TGw8fr5Hp26+azmyBlQWapk5Qzed/aPSucpHZYgODRLUz6bOcDnpD5Xhp++jZd
         GI+TlsP7Zwzg+Ndt1/9JpSZPTLN9dYht58uTf9tPJMVqJIoRvnVsWSVD99uev0djpm5V
         wZTeoB2OHhduJExV5i2r4aimv9ssxxXtaGCxnQquN+yVdpBlnB2URDWbIWZbqkD1V9VM
         Nn1A==
X-Gm-Message-State: APjAAAVWBogFU5njekGEY5phM2mnWZQL/mNLZpgfi06D3rDntiYnDGOm
	Az2xk4UiePoGm9TBoau7HLKF7tl8eyVXtDfMZSHZZKPwrY2vHtQ1DEuQO4zPqR3+ZxP0bd6Bhpf
	S8Qk2EjU2p47F7i9o81Vb1LSnh43rrwmERufWm265XoO0CXcQHwxZr6fEuTpky7Ns/uIFaXjJp5
	7fLlb8Z7YF3p1mXi0m2UsZKnQHsLLBsqlVK9fQU9TZoPe5kqKlMbK3FZLVK8qW9T1CXbSvHJLwq
	Hh4D6d/XiPOf6THk1b5HD1P388Diw/0i331ycwcCpld0Kq6t9swFCJpTTa4lrkT4JmyAMfNVh8S
	5O4onA0I6j7ZdWEIQgyfPYsdC3y92JGz1WGbd0FpaXE5OFNlWw0UG0DXX1NX/uuGNzIZfsI5fP5
	6
X-Received: by 2002:a17:902:2a69:: with SMTP id i96mr20149801plb.58.1552070606596;
        Fri, 08 Mar 2019 10:43:26 -0800 (PST)
X-Received: by 2002:a17:902:2a69:: with SMTP id i96mr20149735plb.58.1552070605682;
        Fri, 08 Mar 2019 10:43:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552070605; cv=none;
        d=google.com; s=arc-20160816;
        b=hgzIoOAXTXJ32Wwd78V98wxRpdJ2jT0t2YuWV3ojZUXG7Fp/agdyBJk/PDWHUrlO8l
         2UsrDrrlw5e9Yx47tLFIqPp+1TnBD3Browji9whRBw8XxJPpAeFsrFpmgNApJmDsdv1T
         BAxeBZW9OL+K9mRY0+sAriFz7Qjz4YEd18gIUruZj+wV/aOvgcqOo3TCMuRgw9D2qmor
         MENGGp2aCUGUkUX4e9SFt6ntnIuKSvWMIPAwthch81NUocrrgQI+PJgJV7CVAcqmnYqY
         OLBMttAU08C0qB9WrM0FpotPIP2rVgbhNADvBPRE6OZsX9x/PVmjH8hd3U5T3CLy+h6p
         CSEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=bO9Ut6bvYRKsfb9hG438t2Q8GfNMLAbUhphxvMlnr+Y=;
        b=jG3CfYHWZ8lo/FXZRjFXpxDCjr9noWy84ZXOc4zxJ2O3s1WhAX08fVX//kA6PPnONK
         gV1UHgfEoF2J8j0IY4HD1OKjwmL4LCN08i/iuZn+/HE1pvXsXqgJbtLvfw1tN8Fnqe3e
         oKiWgOpuJa5nUaNgWrPi701LuiUJg7dz0vPSpGte6Cw5QbnMy8TdE/mS6MkdbwdxRc6Z
         h0qmxamH2d0raDyDY8Y8mUErUATSYVTaBXT4BXdUdmAH63nUaj1JsIckmS2lOZxbjfyK
         EgUWMb+O8Cao+SNQL3qHYGFRmmkiIXo+JuhKjf9QP1hB1p1xpF2OF+UzrDyufSGoYO+T
         QdZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ddj5LQyj;
       spf=pass (google.com: domain of 3zbecxaykcdigifsbpuccuzs.qcazwbil-aayjoqy.cfu@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3zbeCXAYKCDIgifSbPUccUZS.QcaZWbil-aaYjOQY.cfU@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id a7sor13790486plp.1.2019.03.08.10.43.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:43:25 -0800 (PST)
Received-SPF: pass (google.com: domain of 3zbecxaykcdigifsbpuccuzs.qcazwbil-aayjoqy.cfu@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ddj5LQyj;
       spf=pass (google.com: domain of 3zbecxaykcdigifsbpuccuzs.qcazwbil-aayjoqy.cfu@flex--surenb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3zbeCXAYKCDIgifSbPUccUZS.QcaZWbil-aaYjOQY.cfU@flex--surenb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=bO9Ut6bvYRKsfb9hG438t2Q8GfNMLAbUhphxvMlnr+Y=;
        b=Ddj5LQyjlIjwrHP5ehK+oJ/v9fKavvSearbFSnK49AD0M0Ijda7ZsanGy74D80pufg
         Lgkcv8juSAkThYZJjtNfyaTS7N2zDclYu45eWjgibFFwaNK8ylyh0oB7kmipClxsLsWG
         cxV5JRBPuMfAr5RQ52u+RYzzNTQvS3pNMIth63F6imHd2Ft3RZ8Yp5NVHeLn/kPYvo0M
         fkk9E5iqllL6RJSI9Lsi+bUnPFigtvVlPOKMb7S0PbnrLOFx3egU9xt6UxWQIFUF+QJc
         InrzrowbvnHoW34yZXO0BbCSWS+Yn2NAKH9O/c9a5tz3tcc/HyTAjgeMNowOQwuAJCBJ
         tlUQ==
X-Google-Smtp-Source: APXvYqw2C6wbweqasiF1cbPEq10gvpXR3nbBbTemia3F7+b5xQQZgTibnmAJlyRQEfHaibrTPeQ7I25CGVU=
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr6269298plo.54.1552070605443;
 Fri, 08 Mar 2019 10:43:25 -0800 (PST)
Date: Fri,  8 Mar 2019 10:43:06 -0800
In-Reply-To: <20190308184311.144521-1-surenb@google.com>
Message-Id: <20190308184311.144521-3-surenb@google.com>
Mime-Version: 1.0
References: <20190308184311.144521-1-surenb@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v5 2/7] psi: make psi_enable static
From: Suren Baghdasaryan <surenb@google.com>
To: gregkh@linuxfoundation.org
Cc: tj@kernel.org, lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk, 
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com, 
	peterz@infradead.org, akpm@linux-foundation.org, corbet@lwn.net, 
	cgroups@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, kernel-team@android.com, 
	Suren Baghdasaryan <surenb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

psi_enable is not used outside of psi.c, make it static.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Suren Baghdasaryan <surenb@google.com>
---
 kernel/sched/psi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
index 22c1505ad290..281702de9772 100644
--- a/kernel/sched/psi.c
+++ b/kernel/sched/psi.c
@@ -140,9 +140,9 @@ static int psi_bug __read_mostly;
 DEFINE_STATIC_KEY_FALSE(psi_disabled);
 
 #ifdef CONFIG_PSI_DEFAULT_DISABLED
-bool psi_enable;
+static bool psi_enable;
 #else
-bool psi_enable = true;
+static bool psi_enable = true;
 #endif
 static int __init setup_psi(char *str)
 {
-- 
2.21.0.360.g471c308f928-goog

