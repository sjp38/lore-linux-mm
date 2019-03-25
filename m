Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93373C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37AF220870
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 08:23:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rcp7rGow"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37AF220870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E8986B000A; Mon, 25 Mar 2019 04:23:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 970386B000C; Mon, 25 Mar 2019 04:23:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812516B000D; Mon, 25 Mar 2019 04:23:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D85D6B000A
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 04:23:58 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id o4so8826517pgl.6
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 01:23:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=S7mrwRnlFqn5vDrLqD/9JPJs+QFDfh8cL9UHBLJBJl8=;
        b=gnQMKzukhjRLeISYFV+PqeNjw222tGptdZjuk9zmSArpqErs8GjZrNE6uwohs1M4Sh
         PwaLoyw8QvRJ2CLspKfTVnnlTV680oG3ZCFqpctOmUWTGdm6v7siB4877cNjz/GPg9aF
         OlAtiGvGGbDpzHFLvHfh66KKyIpK5Wm2ehFJxy59mgGKpPo8gPttLc1+hTuc39cHrZZv
         gS8tMT12xk3h2nM06s9KRjoAICTygUJb9DjY0DjTdMF4BinHu7crOD1xDBMsBUzs+c8G
         eKJAOd7RSNO3ANX1cPJzWRQOPXXTSB4OOV4qKnqm3s7L5TtJz6/bhyQgytL7rgkE+LmP
         TGCQ==
X-Gm-Message-State: APjAAAUnBaJ77L2czyJuhnfUzmz7aDjcRUhtkYgRC2q6Q/9t5iGIZJuV
	Rw//5FpyVcY0z0eM8NRikD72OTNLZWFBLh+DgG1vEa15mx7HYy9fzs0RfwFBXr2MQF2njGlqbHA
	ihSoeg3XGzgxNtKuWxNaSB/gl/Eh9Z2dCX2vj1ll5QKzAFCbtPLDmGSxlCLmQuB/+xg==
X-Received: by 2002:a17:902:f20e:: with SMTP id gn14mr23804305plb.334.1553502237783;
        Mon, 25 Mar 2019 01:23:57 -0700 (PDT)
X-Received: by 2002:a17:902:f20e:: with SMTP id gn14mr23804249plb.334.1553502236941;
        Mon, 25 Mar 2019 01:23:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553502236; cv=none;
        d=google.com; s=arc-20160816;
        b=IMGvJTkj3TpgUGwab4bMm0oQnRlo306u8zysAzmS6KiPRa4Y3Ht/hDgtGreErPwr4z
         aDxjTB1aG3Qdd1hM7KwvQw6G6gnsYgPqgqdRm7oevyjHtGxzVxx4aCMvcKWXT7taOF1e
         lSYWGqO0eT8N8saH04KQWs1yd5P7SA9llo5k45IqJglpg6ZprpatClIgGQ4q2azJsbON
         SG4JLqfxvcLmpAYzuhXXHRv/Kaf5bMIizYW1X/i2cQOqBTtvn90gwnYKnBJst3NxxKSs
         jP4+Sm++PXJ1mvjd/vk592gofMFRg4+O53Wabd8JSxErqNvS/GGkH39/xuNZWZvLGW+s
         Ca6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=S7mrwRnlFqn5vDrLqD/9JPJs+QFDfh8cL9UHBLJBJl8=;
        b=caoJHaAO9aJ9IFAuMx4nuAYAQ1Bos9AzWRnYzN8ZYRQosUWb1mbdKOY1NI9GMF6i2O
         y6tNHd2TSylnF7Q0KQlLuSwCRJh7ydkXjFbCzJc+uXQZNoLQWZFj77IQc/2p1YFMr6tC
         ssNZv4ltjVC06i9EguMGwEXDn57/qCHQDZJM9OWULrfXPJIxnsR/JWBKSbw08O35QkDa
         +6yvIYoJ+wgB9l4rRhDfVKIpKqzYYnicb9Jgi0YqmlcMri0isL2mRx2nbFIMvtOwfvl5
         Jg+S1CSFDw0KervoYkcIFcaYxyfMuMrsmljQw72D4eeLlp3rP+eB/lrVakI6HLuyZHRE
         wvQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rcp7rGow;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor16156380pfd.39.2019.03.25.01.23.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 01:23:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rcp7rGow;
       spf=pass (google.com: domain of zbestahu@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=zbestahu@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=S7mrwRnlFqn5vDrLqD/9JPJs+QFDfh8cL9UHBLJBJl8=;
        b=rcp7rGoweoMGEk0n3KtxZMYgY/aooq2jlzlfTjYCVOTjYxcHqaz3jwZRhRYoUBIkgv
         K9I0mBD5kGrhOKXa0Q7N8IW/Z/g3fVfGYdBg6pcvhvDNYyk1oJ/GukC6FEgKZ967smYc
         JwBevulcDNBZZdUZobHw0Mf+IYaOaK+cT1Zgjnb3SKlHPd6qCZA7FLtdqYzKgoeE5rvv
         8HO+Hu8yk11eAYUiaVX7LBD9ep9wtAuyZqumjtKRvAOdkIxx164W1apVLfXv0oyl449V
         5SgB4E3sZw44yhGXydLidzJgbehB1smG+5l6x6Spl0SLkb1drZ+wRwpfWWrAGE7qlhXF
         rQyA==
X-Google-Smtp-Source: APXvYqwIG8QXywIh101OeC6O5lcDHVTiyt+YCrMCEM25gDYICdPIIztdSe5TkWDIl57XZyivcHbgiA==
X-Received: by 2002:aa7:90c7:: with SMTP id k7mr22612113pfk.186.1553502236642;
        Mon, 25 Mar 2019 01:23:56 -0700 (PDT)
Received: from huyue2.ccdomain.com ([218.189.10.173])
        by smtp.gmail.com with ESMTPSA id 139sm19202755pfw.98.2019.03.25.01.23.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 01:23:55 -0700 (PDT)
From: Yue Hu <zbestahu@gmail.com>
To: akpm@linux-foundation.org,
	iamjoonsoo.kim@lge.com,
	labbott@redhat.com,
	rppt@linux.vnet.ibm.com,
	rdunlap@infradead.org
Cc: linux-mm@kvack.org,
	huyue2@yulong.com
Subject: [PATCH] mm/cma: Fix crash on CMA allocation if bitmap allocation fails
Date: Mon, 25 Mar 2019 16:13:09 +0800
Message-Id: <20190325081309.6004-1-zbestahu@gmail.com>
X-Mailer: git-send-email 2.17.1.windows.2
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

A previous commit f022d8cb7ec7 ("mm: cma: Don't crash on allocation
if CMA area can't be activated") fixes the crash issue when activation
fails via setting cma->count as 0, same logic exists if bitmap
allocation fails.

Signed-off-by: Yue Hu <huyue2@yulong.com>
---
 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index f5bf819..991a6ce 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -106,8 +106,10 @@ static int __init cma_activate_area(struct cma *cma)
 
 	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 
-	if (!cma->bitmap)
+	if (!cma->bitmap) {
+		cma->count = 0;
 		return -ENOMEM;
+	}
 
 	WARN_ON_ONCE(!pfn_valid(pfn));
 	zone = page_zone(pfn_to_page(pfn));
-- 
1.9.1

