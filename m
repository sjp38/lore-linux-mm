Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE0F9C04A6B
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 02:37:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72555208C0
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 02:37:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Gzy2uqxx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72555208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFFB16B0005; Sun, 12 May 2019 22:37:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB07B6B0006; Sun, 12 May 2019 22:37:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9F296B0007; Sun, 12 May 2019 22:37:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 816246B0005
	for <linux-mm@kvack.org>; Sun, 12 May 2019 22:37:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s19so7472813plp.6
        for <linux-mm@kvack.org>; Sun, 12 May 2019 19:37:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=VU3aFBFKq8lpBvO42+887yBZzGyg8zhfJfkDGxXu1Ng=;
        b=XFWrZCbS1gkZe5UdZO+Ca0XVyRHH30MWW0FqbOygTv2gsDe9KcghksVWP9boAOnC6F
         Q/MTlbVpkf1s7jr2j9evfzwPV1CpAOwHjHYwEF+4pd8BaWK2rjwniCLZFvE0xM5iPtiC
         LFn0sIWLxZzfUwwnKOHyD8RYXc1zJtADMZ/eGtTzmOAqvAzY8tVJ+NU1so30HdlqEZvH
         K8CSzzxW69Vi4WIe/vfZh1Hq+w9KwRhE36IE+/ZlxjPhZbn9Hf9Z8Vsbr8YDbhqdQgTQ
         bF+GmrIyD15P1T+xovAXxOaRlrTGcz1TVko7CqtFF261vO9yM9NfMvGrECSQhjxvaa/H
         AY+g==
X-Gm-Message-State: APjAAAWxfwMx+QsfcGlRPlOkzWORHAknKVD1/sgIUtPcrxSFVarM4xe7
	xoCNwLJO6hBT/yNioGn/ZXk0MkkUD3fzN6jI8ko6AZRRxWZbv5lTT4ab9ZN38/u3ACwv+TfBalI
	VBYCU/awLFLweHcyVHM1MGoYoI/azYmd6COQJ0coQ9695n8rIMEbdvDkNDWDWirI5RA==
X-Received: by 2002:a63:d949:: with SMTP id e9mr28080188pgj.437.1557715035435;
        Sun, 12 May 2019 19:37:15 -0700 (PDT)
X-Received: by 2002:a63:d949:: with SMTP id e9mr28080124pgj.437.1557715034212;
        Sun, 12 May 2019 19:37:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557715034; cv=none;
        d=google.com; s=arc-20160816;
        b=z1CPx7Gs8Xol1uOlG7Jmfpb5WgVGmxzUFWRAtkQJbeowYgDqqrI6piIL4ZM8p6kIV5
         DyMtf9J9zG//hFwdJO7K3AsZ9CYhoIAhjwz4XIRAe892/k6Yerk38dxpu5rR20/JBgjj
         UBT/uB2+OOHpeXxsO3abp+29SMbW/ei49IpJUD659be3vRFoJmo0QDXDHQnF1/khQddl
         ScxUwB8tIPKROi1PDAZXGEbhjnGYqsedUHe5o7nBTVY/NweXdF9haPsvN4IkMF1uEJ6i
         g4koMcAXKArwieC1+3Udk3ACATMm0efsSnsPBC0g2nU7XZ7ROgKSm3+JbjoWpV6pLz56
         nPJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=VU3aFBFKq8lpBvO42+887yBZzGyg8zhfJfkDGxXu1Ng=;
        b=oJm6NvRd4ZA0BGPw4Kwa8vmWzDNfUc6vgZuPVOKUkqQNS5abNHsW4dmkgcTtFeTj2i
         7QaGLq44B9HXtQDt1jUcB/ClLOPhXHNfMu+0SYiiFfi1kq3NatcjKed+1MMGJ88TwMvc
         4tbGOacFSGe1qIh2VphywHz4yzQofet/eee9bHqhCy9UNrJxp/07Iq9LSGegOaM+6G2r
         5XlwDE2HmqtR4XmP72OPikGrybRtePY6tnNGwzOidt9uUBIvzByPFe+Pk8Jj1JLvo/Xe
         umCoHdNB++kw9EWzTORZqTnu55eMvgaLIXKKWJKdexdxgE0ZNQ6Zjczn01uY7FidlGEs
         2f3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gzy2uqxx;
       spf=pass (google.com: domain of swkhack@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=swkhack@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e24sor13026560pgn.10.2019.05.12.19.37.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 12 May 2019 19:37:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of swkhack@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Gzy2uqxx;
       spf=pass (google.com: domain of swkhack@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=swkhack@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=VU3aFBFKq8lpBvO42+887yBZzGyg8zhfJfkDGxXu1Ng=;
        b=Gzy2uqxxKJL0QrBwHfIoV5pxtyqY4VmkeOTa+76twY0ZJ8upgNTDskZo9rx4cP27qp
         9hUy8Nkp73tyKHT/QWmRpZHemAUb0bcFXYh7TLUVKXQvaH/GFgeReSOI9AmA+RPbZZPx
         oWYlpo8XJA7ayia7IY6bMzWr0ZqAtLcfsKN9V6vSSeLo8mIqTTVRRg3pm8O9TRiP7jI7
         kwjcgFTFNc+aIjSqwEfeOUoD/R69+R2k1opHKZ54e4YesggcyOAO4uxkujJeUsgnRS30
         dQnI+fd4JCeda83rvmZcNtWu+uKuU8u5VQn9Oo18OQeZx6PKuLJXRNcLVK48REhOxJQ+
         Nf3g==
X-Google-Smtp-Source: APXvYqxhWOdP+Qg7MYa7LiwMgL/NiBSA0QM3Qjo0JeTAZOTI6qeHYKqjn2tCm4dcvaMlaBODAARnRQ==
X-Received: by 2002:a63:c50c:: with SMTP id f12mr28107838pgd.71.1557715033479;
        Sun, 12 May 2019 19:37:13 -0700 (PDT)
Received: from localhost.localdomain ([185.241.43.160])
        by smtp.gmail.com with ESMTPSA id d186sm11070342pfd.183.2019.05.12.19.37.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 May 2019 19:37:12 -0700 (PDT)
From: Weikang shi <swkhack@gmail.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	swkhack <swkhack@gmail.com>
Subject: [PATCH] mm: Change count_mm_mlocked_page_nr return type
Date: Mon, 13 May 2019 10:37:01 +0800
Message-Id: <20190513023701.83056-1-swkhack@gmail.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: swkhack <swkhack@gmail.com>

In 64-bit machine,the value of "vma->vm_end - vma->vm_start"
maybe negative in 32bit int and the "count >> PAGE_SHIFT"'s result
will be wrong.So change the local variable and return
value to unsigned long will fix the problem.

Signed-off-by: swkhack <swkhack@gmail.com>
---
 mm/mlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 080f3b364..d614163f5 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -636,11 +636,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
  * is also counted.
  * Return value: previously mlocked page counts
  */
-static int count_mm_mlocked_page_nr(struct mm_struct *mm,
+static unsigned long count_mm_mlocked_page_nr(struct mm_struct *mm,
 		unsigned long start, size_t len)
 {
 	struct vm_area_struct *vma;
-	int count = 0;
+	unsigned long count = 0;
 
 	if (mm == NULL)
 		mm = current->mm;
-- 
2.17.1

