Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 933B8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54C202087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:58:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="jhtZjyqO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54C202087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02EC68E0006; Mon, 11 Mar 2019 15:58:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F20CD8E0002; Mon, 11 Mar 2019 15:58:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC1B08E0006; Mon, 11 Mar 2019 15:58:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 967EE8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:58:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o4so16395pgl.6
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:58:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gHjs0RV0DMUwLbXh8RV3aR31ekxqNi7TvgMu/pwgEp8=;
        b=PXV95FjHfSym+MFiXNAGxty55RmTJ9IGqa5F5ZXS69gKg5Gdpjb7Li66mr6RRW/b5+
         XUsaBi38a4fewUzc7tB+N6JkkQUlJP7hU2/RrHJfH92cl+wzEQg1eNE652v8LQjQL1yp
         /28JRHeNMYs3K5/jdwdwZeQheZTW9ENSwE44o3Gs7nGjtBfuBnpW1GW211wt6+peNNEC
         xj6gHdtgRvQTKQmy5Uwi+mfNVA8KG8XvGwb0eg+J140wXef5vRogqHJYJEpNurKOmMmw
         1gjJT/eEf5h2dSuJ17dCc/hEbfw/QaLc/H5p9gJ00+5+MarI6ERZgpYcp6R1YlZQqmKo
         y6Jg==
X-Gm-Message-State: APjAAAU9tFwLNUwHL8heNPvoVm2prxjoEcsLaEfmdZ3Q3kc1IDHUuXD1
	0/g5inICX5Hn+MLkprt9Fzjc6c/7B92I6SY69/p1e8yvnyBHipwseWYfPMIxcE8pGfnDR9/T8St
	LcPcXllac0/Q2Dy13mHCO0fccZVL8lJFSPVJkGj526bwUQyMQnu02HGfD35hMdSXDhw==
X-Received: by 2002:a63:43:: with SMTP id 64mr31293513pga.64.1552334337308;
        Mon, 11 Mar 2019 12:58:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/RYzcUHHJwl2MlSeeN4+OctkxZW4pn0X6vvv5/zxpT9R1ShKvpJHOmQOpsUSKdG5hTJ9d
X-Received: by 2002:a63:43:: with SMTP id 64mr31293474pga.64.1552334336580;
        Mon, 11 Mar 2019 12:58:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552334336; cv=none;
        d=google.com; s=arc-20160816;
        b=p3G2VuAaIouht7ACmHEq+9uCjPwnViTQCQxZunbVRYwBGCi5ZpkvtTri47maGV5Uer
         KyT+0h9T3ndmmE5hBHDuMuZKffCwnBPjPKsBIsWci8tzPfEdiFMF2XVFzPEaFPUdrvTc
         umcvp7xmBNQFvmc5eojQVzK25We8tH7D5QvLi2QouWyrPYMDzp0QYceWXojiXee9ep/G
         7CST9GdRTrmtorMeKRpjjhPVGW2P56VUiv0Ztgdbdg1jvqpW95t5BGPC0DS9NhlODLkM
         t6djUybfXAlcVAm06ZTZ10kItdEr7VhKAvrLREwJOMBqJE22nFckgIQEbQj+aMEcqGdu
         k6gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gHjs0RV0DMUwLbXh8RV3aR31ekxqNi7TvgMu/pwgEp8=;
        b=dofEtAMcUmBed/NKUzXuMocPd4tSuveNrhY0a1g+dQ7wz2iiIgvcWwt+t+PX5RU4x4
         Y3p8A966Q8zRooyR7jsRd3lMepgFLTWUk4vVTMLxFXT46O2krGXGH/Uz+TXwEctTh33H
         Idpa4zJmuNd4uNfuBQJAp3jG7hkMu6xz/HINv8FPsyk0LPzeeVZQyYXM++ycW5Qu+wRK
         280yAqZe6uJoJkQ1LDRnrFa2CGcaE1IRJUSjkTURodyXkHxxAnBT4GkjilrplSNNjk6V
         qK71/dt/t8OuVo+l9qCVtNxMkZDOztV5NggPvzp8/wxXF2HZJNUryTY8go7Qkxrrf8x3
         HNCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jhtZjyqO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r6si5821570plo.269.2019.03.11.12.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:58:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jhtZjyqO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 98CFC2084F;
	Mon, 11 Mar 2019 19:58:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552334336;
	bh=c4WhAd0lVraK0PC+Zlud1g9h5gTXUP3stopd1mYPUDA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=jhtZjyqOk6vNtytQnIT58ifnfMFmIGVzPB9TMJJH1u8kZgstPU42HjGazfrWrz036
	 qOIIU3D2091a1YN5oCSybtvFsQ2/ilqAhmJUMas2hQnvQwZjOMw1GF4Ff7YdgUj2LU
	 nvSvGzInAOT3f0kuwStt4W5x3APrWo8NPPsJ/vHU=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yu Zhao <yuzhao@google.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Keith Busch <keith.busch@intel.com>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 20/27] mm/gup: fix gup_pmd_range() for dax
Date: Mon, 11 Mar 2019 15:58:17 -0400
Message-Id: <20190311195824.139043-20-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190311195824.139043-1-sashal@kernel.org>
References: <20190311195824.139043-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yu Zhao <yuzhao@google.com>

[ Upstream commit 414fd080d125408cb15d04ff4907e1dd8145c8c7 ]

For dax pmd, pmd_trans_huge() returns false but pmd_huge() returns true
on x86.  So the function works as long as hugetlb is configured.
However, dax doesn't depend on hugetlb.

Link: http://lkml.kernel.org/r/20190111034033.601-1-yuzhao@google.com
Signed-off-by: Yu Zhao <yuzhao@google.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: "Michael S . Tsirkin" <mst@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 4cc8a6ff0f56..7c0e5b1bbcd4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1643,7 +1643,8 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 		if (!pmd_present(pmd))
 			return 0;
 
-		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd) ||
+			     pmd_devmap(pmd))) {
 			/*
 			 * NUMA hinting faults need to be handled in the GUP
 			 * slowpath for accounting purposes and so that they
-- 
2.19.1

