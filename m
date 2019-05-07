Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72152C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:41:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 096B12087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 05:41:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="SG7t6wj5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 096B12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A26F16B026A; Tue,  7 May 2019 01:41:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D8386B026B; Tue,  7 May 2019 01:41:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EF4B6B026C; Tue,  7 May 2019 01:41:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57A8B6B026A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 01:41:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i8so7109868pfo.21
        for <linux-mm@kvack.org>; Mon, 06 May 2019 22:41:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RrHFjAcBsqe8mEBrDqPXaQne4gotRiQR0ivbmtbB/5A=;
        b=A3HDl/MIyNCPs9OFqMY+8ykAC86GzauXU5d6+vk8H1RPF+/bZSra+5qbqgUcd4d4dZ
         nimMokvKpqlglCzpK7W7M3or2EHjq4FCsL+GLpJmEwYkZDW8VJZQUceqiUivCpldDeEa
         TDn3cFGmt9Yc2qm4KeTk/P/E6uPrGhEeVPtFKp9vZyn3gCHJX1BwLzyUeZcHI0Jpwgb0
         b9hAyqf5LTEf7VcCwP+ErdRV5s+oFjL9ZlRM64ecUqSwPf008h/iEdx2o8+/etF8Khjq
         aWFkN+h5IasSYwODnzk/Gzh/dIfXVsdXtxxSD6VakgMeW7kXPSb4R4Ox54DQOoJEgmkv
         za2Q==
X-Gm-Message-State: APjAAAWNX+SZFWv4IcYkJmvBRJjR1Eo7RyFprtj2zzS5D7eXO4JFQx+8
	0t6GG/EQNK+5+By5hS3vM1fRQTsi/jkOcbIyBTCj7br8Y6hLKxiOVHjQkrXE/IR4MKC+iXOMNw4
	XEBkPyCEeXUdC6S/zjDwXlQaj7LnHfZKPe/gPmficcFaB2QE6YK8AEYOOdSLWwRsGlA==
X-Received: by 2002:a63:9548:: with SMTP id t8mr22085843pgn.256.1557207670011;
        Mon, 06 May 2019 22:41:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIBKtsPzpzXXX8OrUCULjZh/mqqP0prti7KeGNxkD/fiiZ5US1devXb9wM/e/plJf7yJjh
X-Received: by 2002:a63:9548:: with SMTP id t8mr22085785pgn.256.1557207669305;
        Mon, 06 May 2019 22:41:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557207669; cv=none;
        d=google.com; s=arc-20160816;
        b=KnSLKnQ+qhmX7P32iUkO1J/MCaPo2xaebw25HnTFbFMWvSglkTUAmXhh63AbPkuI/K
         gXfadbA2SXfAzzv9C5dcNwY73u60He1XIdvy/xoBugIwCvL9UXhXvXXQ5Iz4fSIZgfCY
         m8TpugCQQlKh4MYH0dNPaIkFlGCbsfVZJWjAXUJxh/OfGILg/5Mdztp+HY7FAI2VuAk0
         ykBk8pR1eDzpH1l0eLtvgZecdNLDhs5u6y2bEIZ9ZqDcybkK4y7UJeWSJ9XhlfI2wj6W
         BmHM46G6odGgW3Jz9ha3IBB0rRQvTH55DsZOTvL7+MWRZ+POZ7TcT2FFsD/utUu34CX7
         1gPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RrHFjAcBsqe8mEBrDqPXaQne4gotRiQR0ivbmtbB/5A=;
        b=JbCrJpQ1QhheLRmdLCHoBgs79HEGaSo+Zrhf285Vxz7yvj8mxa+aASWqHzDwornqgo
         7w5nc5GFVa2FEXT4or02kV9/8nPuDxzuEm6rIYqb5hHO9LQbPFaW4q7wNMECPNAx7l5o
         +G4CVhT6K0HWMF9qWAv8TmNnM5cm6pMcS/4wjZFWiNyqQ4FQc2NlC8dUmXYS/GNStMRz
         FHDFWYrJzoZCf8r7vzkQGEpVZ6uSWmjzXkUrUts+n2JDJzBLxlzyC2fwP7/T2RZgQfFR
         nADtSWXC9dqDn0MhB1RtFNMyiQc5AljIQmB6YNsQQ6VuPJZgpWtn7JVeIkgDgz2Fq4Jc
         brFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SG7t6wj5;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x3si2774107plb.347.2019.05.06.22.41.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 22:41:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=SG7t6wj5;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7E612087F;
	Tue,  7 May 2019 05:41:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557207668;
	bh=uyUWu/YRvdGkGjQJJaeNKgUIULFg6yFhSnXMrgmgQ7Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=SG7t6wj5i32/ut6d+tUQ5CJ1kGzimuZWBHt2uucGBYd+ohFjxIZyXRJOYdmdxQtiL
	 snVUJBO/cFTbehyTEnPoLBU4RgUy7LMnAIGTnheyzclUtW7e6DvKcXs1DsawdLPicS
	 CXaErRITJAVhq6CXH5J/7O0PJHxg3FOUIyq38Qjs=
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
Subject: [PATCH AUTOSEL 4.14 86/95] mm/memory.c: fix modifying of page protection by insert_pfn()
Date: Tue,  7 May 2019 01:38:15 -0400
Message-Id: <20190507053826.31622-86-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190507053826.31622-1-sashal@kernel.org>
References: <20190507053826.31622-1-sashal@kernel.org>
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
index f99b64ca1303..e9bce27bc18c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1813,10 +1813,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
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
@@ -1825,7 +1827,6 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	else
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
 
-out_mkwrite:
 	if (mkwrite) {
 		entry = pte_mkyoung(entry);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-- 
2.20.1

