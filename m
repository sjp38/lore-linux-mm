Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8C77C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 11:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A4AC20828
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 11:37:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h680x9OG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A4AC20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E26B6B000D; Thu, 29 Aug 2019 07:37:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 093B46B000E; Thu, 29 Aug 2019 07:37:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9CB16B0010; Thu, 29 Aug 2019 07:37:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0023.hostedemail.com [216.40.44.23])
	by kanga.kvack.org (Postfix) with ESMTP id C7BCF6B000D
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:37:35 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 682A2180AD7C1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:37:35 +0000 (UTC)
X-FDA: 75875265270.06.lead19_5f4faca4aa93c
X-HE-Tag: lead19_5f4faca4aa93c
X-Filterd-Recvd-Size: 3538
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com [209.85.221.65])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:37:34 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id c3so3067585wrd.7
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 04:37:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=wi+aEk/lw/SC/EWGJj1b2gUv3dj2gmXZvpclD3XWmxM=;
        b=h680x9OGpM5D0HrHC0ResvENTHF6DUz9UMMsvEad9yRxXJxJ2pjr+CWYAeXvbwzS9F
         i9dZjIlg5bMGzRIp+RmUFAuq3/xqzNKT8g+JGxOwBjaImT7Js5daWRH3QFb2uO1pURan
         PBBc/11pFcKYs2TkLApCthIChjZPDNk/z3gY1yYOvFvHlM9pBbMRY38KbcX1Qa99R+7k
         h7rHySUJcocyvK0Nd9HjME9/RLiaBVF4GxeE++2aMudRkgxh3IZHl7etfEqX2jwcpddC
         D9O4/+K/j4RqzGO4qnq2nC2S7jM111uS5TsSe4CYwsm7T/b8VDjJ6gfhH2VYU9WP+m2x
         YHcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=wi+aEk/lw/SC/EWGJj1b2gUv3dj2gmXZvpclD3XWmxM=;
        b=dKJP5fI7rJjthVoU+Ct5UKsLkreVbZRipo8wlT0u1EOhthzPV41QoqvRXw8l3Vq+sS
         iDaRyok6yx8F20h1ixPrmmE+y0rf157ZiT1Ubu4anyz03ot4NBp7mSySyr1e9KvL2qQu
         Jhi2XGRXSuoAiTJUEHgx8DBFWik9uHh1wzQvRgW909H446sy6QTOkPcKbmkV0uDkp5cZ
         0ySzkmLSCihS45W/uLs+2uSD3c0KkYSUYcHDzF0ANM8yVkpcEBY+3YtIbvIeiLGtn65x
         +1a03Zp6k9EamK700kF8WKVeeBlzL1uQv7xgjxKIeDlEf9hpDGVKaXd0G6tPVhhCkHtk
         CidQ==
X-Gm-Message-State: APjAAAW2ioK9x+JmbkDztUIWhHBjWk2WjZ/TjRYy1ivEZ3633fptmpeE
	eKYgMFd0UGmATAXHtcBpEl/vBLLlUlvuaz/wDmU=
X-Google-Smtp-Source: APXvYqwp0esAayMYR7QeT6qJZa7H6Kht3QsdHVcep8OrxN4J+qQh8oblAaUjk/f/vf9Wep6v/haceClU1LQfsday0ko=
X-Received: by 2002:a5d:4a11:: with SMTP id m17mr675507wrq.40.1567078653582;
 Thu, 29 Aug 2019 04:37:33 -0700 (PDT)
MIME-Version: 1.0
From: zhigang lu <luzhigang001@gmail.com>
Date: Thu, 29 Aug 2019 19:37:22 +0800
Message-ID: <CABNBeK+6C9ToJcjhGBJQm5dDaddA0USOoRFmRckZ27PhLGUfQg@mail.gmail.com>
Subject: [PATCH] mm/hugetlb: avoid looping to the same hugepage if !pages and !vmas
To: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: tonnylu@tencent.com, hzhongzhang@tencent.com, knightzhang@tencent.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhigang Lu <tonnylu@tencent.com>

This change greatly decrease the time of mmaping a file in hugetlbfs.
With MAP_POPULATE flag, it takes about 50 milliseconds to mmap a
existing 128GB file in hugetlbfs. With this change, it takes less
then 1 millisecond.

Signed-off-by: Zhigang Lu <tonnylu@tencent.com>
Reviewed-by: Haozhong Zhang <hzhongzhang@tencent.com>
Reviewed-by: Zongming Zhang <knightzhang@tencent.com>
---
 mm/hugetlb.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6d7296d..2df941a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4391,6 +4391,17 @@ long follow_hugetlb_page(struct mm_struct *mm,
struct vm_area_struct *vma,
  break;
  }
  }
+
+ if (!pages && !vmas && !pfn_offset &&
+     (vaddr + huge_page_size(h) < vma->vm_end) &&
+     (remainder >= pages_per_huge_page(h))) {
+ vaddr += huge_page_size(h);
+ remainder -= pages_per_huge_page(h);
+ i += pages_per_huge_page(h);
+ spin_unlock(ptl);
+ continue;
+ }
+
 same_page:
  if (pages) {
  pages[i] = mem_map_offset(page, pfn_offset);
-- 
1.8.3.1

