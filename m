Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EDA6C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:38:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF43721530
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:38:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cJzielO5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF43721530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8079B6B0266; Tue,  7 May 2019 01:38:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 791BE6B0269; Tue,  7 May 2019 01:38:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 631786B026A; Tue,  7 May 2019 01:38:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 256D06B0266
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:38:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i8so7104774pfo.21
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:38:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WKo7YX/uNJiY82oYSrnUJwaq4R2g4TJwB1egJ0ChTpY=;
        b=pmXuWqa2/A7BG6vDJMtn/xVoRXkCIlr64UcM1sD4AXF4sDpuQB3O1kSr9TmWCmoRXX
         05UuNlbszyFujFZpf5nM4fPvS6LybSdJHkuHVu+k9tkfZj6mJFnXjf9Pn7a4J5GMe+TS
         PkU4xxuom8DcFqaTYlrx50204TdGRPRxta9YtABhvYo3/ud8Nz/VAq7lDz53zkzU3Zpy
         Fq/gV2jSnb/gNiq5y1Del/Jo23/fulluWhw57P00XfeCEkh4Lfr5HXWXFi852P8RTuvn
         GOfOsCUeZyjxP2d0/MjEtIqqRf542p3orx5l0ca86iv6kTuffnaRkBOMc7I4sld7Htt0
         uTOg==
X-Gm-Message-State: APjAAAWGGKj943WCJ24Y7zYUol5Cb8SGMUqjc19YGJWEBCCU9gjptUZY
	wCt8s2CM1dvCOlIO25s0F+qAcu4XAlfecCNsVqlLWVU6u++cjz96JMm5+r72Pq3wpgZc4i6+N2N
	7p9abHICob8hexY4ADSjpGJSmFTJogix6kYPQqbE0P1sJGLp1xt02Eht+UCkFD0E0wA==
X-Received: by 2002:a17:902:822:: with SMTP id 31mr37204260plk.41.1557207483805;
        Mon, 06 May 2019 22:38:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgUq8ycRkpu2/lpKSqOoKSny3CZjzM02OV7BGqG5gH7K7B3Ft6MC+9IFyuLH3gLU4yougG
X-Received: by 2002:a17:902:822:: with SMTP id 31mr37204218plk.41.1557207483170;
        Mon, 06 May 2019 22:38:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207483; cv=none;
        d=google.com; s=arc-20160816;
        b=v78p8rBXzvBDNCd2OX4ZTibL+xsZzEd56kvuDHp5EtQTiYTQuuWjbIx7VJoLWeSOL8
         tXnKhi+E7FaihAHpfg0iFrbTID1SDpTAiuG2FC/lNLPLrxOrmDhbChUFJrxHX8S/O9O1
         MkGrHvEP5oc+sbxwy1SiU/qDKOic8ztJ9NlaO9foyJNxbSY8Axdg+T01nrNqkMdVnjdQ
         24M47Exl9ERXa9fxrQEJKKIU59ApH0RGqsqbJerO0LF5cycfQc0hxX3OtjbQ+bYUKOph
         trvrnLCyPeK9b2W1PdLiaO69DRS9c8rpBsALBoZiBtRAF3urSFEmJDZZsYOuukqOgxpl
         rgVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WKo7YX/uNJiY82oYSrnUJwaq4R2g4TJwB1egJ0ChTpY=;
        b=VFNuvub+Aud782UCaQ1cPSuFga9pDzr0O9For7oKuhUALeeqv0eThD2VmxE/Ixczcd
         RHxQtbR7M4C0G3JtDCS0EuRDKeC4xMZ/UrO21ubRYZMpIk3OW3UDJbdBAaT0CR7ItamC
         eOp3oP0zus5BGNitfMv+HBH25bpJ9FyQsQEccl0WxzHr72CzBXH7/cbWIflyeXBuQ6kA
         FcA/S+60Jv4kS17budDTgM5BfH484zM9/BawNuwsNk2tM/cfB3lDSAJhZsrmsNOfTCrI
         s0WjLMca0VlLt66a6WqZ3Z7NzkVPp4bVpCnwqy0Hd0kPAqCUQ6329YhenlU04hPCCIzC
         Wyng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cJzielO5;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h66si14331162pfd.205.2019.05.06.22.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:38:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=cJzielO5;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C11A421655;
	Tue,  7 May 2019 05:38:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207482;
	bh=y9ZLVXMrz9krp9KqLxl4O+qrXhLwZoiMvHNYlQn2wu8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=cJzielO5QAPxr5NXCU89nVN8nPJnzsYPuPtBAZGRWiZoTtL30Hh1rt72TISAzZif2
	 MU+Uk5v5s1Jvx9jHSvOxFb+mtUmeubSBJJsNRRMIs2YV2QuRR/yCi9G6S7qxRzmgs9
	 6ObaPFkKUtUDJW1vG3fdmSoaNGt1BFX59h/D15rM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Chandan Rajendra <chandan@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 67/81] mm/memory.c: fix modifying of page protection by insert_pfn()
Date: Tue,  7 May 2019 01:35:38 -0400
Message-Id: <20190507053554.30848-67-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053554.30848-1-sashal@kernel.org>
References: <20190507053554.30848-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jan Kara <jack@suse.cz>

[ Upstream commit cae85cb8add35f678cf487139d05e083ce2f570a ]

Aneesh has reported that PPC triggers the following warning when
excercising DAX code:

  IP set_pte_at+0x3c/0x190
  LR insert_pfn+0x208/0x280
  Call Trace:
     insert_pfn+0x68/0x280
     dax_iomap_pte_fault.isra.7+0x734/0xa40
     __xfs_filemap_fault+0x280/0x2d0
     do_wp_page+0x48c/0xa40
     __handle_mm_fault+0x8d0/0x1fd0
     handle_mm_fault+0x140/0x250
     __do_page_fault+0x300/0xd60
     handle_page_fault+0x18

Now that is WARN_ON in set_pte_at which is

        VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));

The problem is that on some architectures set_pte_at() cannot cope with
a situation where there is already some (different) valid entry present.

Use ptep_set_access_flags() instead to modify the pfn which is built to
deal with modifying existing PTE.

Link: http://lkml.kernel.org/r/20190311084537.16029-1-jack@suse.cz
Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
Signed-off-by: Jan Kara <jack@suse.cz>
Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Acked-by: Dan Williams <dan.j.williams@intel.com>
Cc: Chandan Rajendra <chandan@linux.ibm.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <alexander.levin@microsoft.com>
---
 mm/memory.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9c69278173b7..e0010cb870e0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1796,10 +1796,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 				WARN_ON_ONCE(!is_zero_pfn(pte_pfn(*pte)));
 				goto out_unlock;
 			}
-			entry = *pte;
-			goto out_mkwrite;
-		} else
-			goto out_unlock;
+			entry = pte_mkyoung(*pte);
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+			if (ptep_set_access_flags(vma, addr, pte, entry, 1))
+				update_mmu_cache(vma, addr, pte);
+		}
+		goto out_unlock;
 	}
 
 	/* Ok, finally just insert the thing.. */
@@ -1808,7 +1810,6 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	else
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
 
-out_mkwrite:
 	if (mkwrite) {
 		entry = pte_mkyoung(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-- 
2.20.1

