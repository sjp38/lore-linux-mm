Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07AA0C46477
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0826217D6
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 15:20:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0826217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7084F6B000D; Wed, 12 Jun 2019 11:20:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6917A6B000E; Wed, 12 Jun 2019 11:20:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55AF36B0010; Wed, 12 Jun 2019 11:20:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id E55BD6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:20:37 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id r1so2740882lfi.22
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 08:20:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nXeAn+b9rzfB9xUtBdzEuMbNYPo06z76iQWWf55VKQQ=;
        b=LOizHccxaQXAbetZkkS9QCJxyn7HLGL+x61OGIUS5g+w/a30rsXfdXIl6eZPd9wBM8
         UW7UGs3NFxkf6xkByWej7ephVn0F4+3OiF+OhiasfV5o537SbAwtt1RtL/QQsryadL5R
         LsVtN48RK6A+JEycDiqm8nUIjgr/ct1Gc/ymWoP4up8Qho8af1nVbd/4e4hBZfn5BASg
         G/318tNUqkRz3325S1OoUmSOiPc9qz4wvXQTSxTtuQTcQjDCacAQyMJM6usgEKrKJL4W
         mub8Rn39g8l3xWeKwLla+1xs5rsslhlqG4ITPz5NrcsPTIvggCtgBCPnOIQDONU5Dw6l
         A+Xw==
X-Gm-Message-State: APjAAAXKofVxqd7q7SjcG10WFN2LbIjWYmkuxmZGFxfk9kT3imzGSzFd
	Fd70IrmZTJSwwP56DwsY0uDj+vhb3x6yAIHjjLVbtq2/LYtKGkmnNjukMPw+nA/+sz+B6VwghLC
	RV4kEfVZjjBprdCKQYEHAwsZgwRH8co+AE2MxA12FMUBH42qq8cNiOqZxYHt6T0s/lQ==
X-Received: by 2002:a2e:124b:: with SMTP id t72mr35621235lje.143.1560352837396;
        Wed, 12 Jun 2019 08:20:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvsuMTBH3glpDUlIN6sTr9fija2h5ThD9hsa5ZTL/xw+FffjOez3M610tQ70QGVVM6RAiD
X-Received: by 2002:a2e:124b:: with SMTP id t72mr35621186lje.143.1560352836098;
        Wed, 12 Jun 2019 08:20:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560352836; cv=none;
        d=google.com; s=arc-20160816;
        b=XNibl+VlnzahpLhP29hefU91T0YRDOIZggbuCvsPPBJeqMqudEnzO3B3DEOXcdxetp
         vZKGwWag7sLlpnkn7zL9yJve7aEm11yNWD5cc6rpXHnMAhY5BA23f2YVVInpBX3ljoX2
         Z1/AwjPX3mKGlQOLiP8hh2e8URYvYQ/jv02hnHIdkxP5WTw9qPB5uab+s+9evZB3p8mW
         hP89pQ46yc80wquQ5GgB4lZ83L0nh5yxwPmkAmIoIAJKBdPMJ7xHn30ZzCofMVqBTJmp
         LiBjOvMDnejSBfTDNduM6NF6FSxsj/O/FBL3SyCS5J63M16YtyEFwZdRcaCCFuUGysKR
         L1fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nXeAn+b9rzfB9xUtBdzEuMbNYPo06z76iQWWf55VKQQ=;
        b=AS7GQpLNyQNvxL9g7NVu54kqycb8+aBXBn4uTEvbOjyMouBBNqfGmCHk+3Zp/NOGgk
         OdsRJ9KVTaoRVUCQ8GMzbvqp+utEBh/DNlvE1x0WFuAKfURuIqYZJgC97OOPzIv3sOPS
         qlQMBkgBMqHxlJ8LrhJiHq8+tWOnDVUl8prdgCOPrgIm5tFH5RMutfpCcWvdd0PDgArF
         Lh3wm3V8IWDn+FySMMJuKuBW62jrm5M2S5VtvrQsHszahADb5Cqv1AeOSPFSboNrPQnC
         G78MDotdRzDLePNxQqyKTsVlyL29qWhluBNvFY0KnQi81XskE30Cs99+SowdQqCRnwvl
         TcVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=hrUiLx4A;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.41 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from pio-pvt-msa2.bahnhof.se (pio-pvt-msa2.bahnhof.se. [79.136.2.41])
        by mx.google.com with ESMTPS id r14si14573183lff.125.2019.06.12.08.20.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 08:20:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.41 as permitted sender) client-ip=79.136.2.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=hrUiLx4A;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 79.136.2.41 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by pio-pvt-msa2.bahnhof.se (Postfix) with ESMTP id 78C33405E5;
	Wed, 12 Jun 2019 17:20:25 +0200 (CEST)
Authentication-Results: pio-pvt-msa2.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=hrUiLx4A;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from pio-pvt-msa2.bahnhof.se ([127.0.0.1])
	by localhost (pio-pvt-msa2.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BRzntngxnE9y; Wed, 12 Jun 2019 17:20:11 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by pio-pvt-msa2.bahnhof.se (Postfix) with ESMTPA id CE9B540572;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
Received: from localhost.localdomain.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 66BCF3619C2;
	Wed, 12 Jun 2019 17:20:09 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560352809;
	bh=Yjmtl92sLAlEoB99F5XOnCklObajAbb4hpy0froOh7I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=hrUiLx4AvjTxhRIGA/Le208AGL5hCC+aKe6Dz4kO+DpO6X5QQvqpLbFyVuFYDtcxw
	 DYgkI865pUqk1xhr/Ll4LTcNoLDpGuYApq9k/aCny2d/E8wUCYfcn6jp9+0252FYQP
	 gIhv4jRpSlU0NuRCd9EzhtVQRO0U9nNkK43wM9jE=
From: =?UTF-8?q?Thomas=20Hellstr=C3=B6m=20=28VMware=29?= <thellstrom@vmwopensource.org>
To: dri-devel@lists.freedesktop.org
Cc: linux-graphics-maintainer@vmware.com,
	pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org,
	hch@infradead.org,
	Thomas Hellstrom <thellstrom@vmware.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Minchan Kim <minchan@kernel.org>,
	Michal Hocko <mhocko@suse.com>,
	Huang Ying <ying.huang@intel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-mm@kvack.org,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: [PATCH v6 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop the mmap_sem
Date: Wed, 12 Jun 2019 17:19:42 +0200
Message-Id: <20190612151950.2870-2-thellstrom@vmwopensource.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190612151950.2870-1-thellstrom@vmwopensource.org>
References: <20190612151950.2870-1-thellstrom@vmwopensource.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Thomas Hellstrom <thellstrom@vmware.com>

Driver fault callbacks are allowed to drop the mmap_sem when expecting
long hardware waits to avoid blocking other mm users. Allow the mkwrite
callbacks to do the same by returning early on VM_FAULT_RETRY.

In particular we want to be able to drop the mmap_sem when waiting for
a reservation object lock on a GPU buffer object. These locks may be
held while waiting for the GPU.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
---
 mm/memory.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index ddf20bd0c317..168f546af1ad 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2238,7 +2238,7 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 	ret = vmf->vma->vm_ops->page_mkwrite(vmf);
 	/* Restore original flags so that caller is not surprised */
 	vmf->flags = old_flags;
-	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
@@ -2515,7 +2515,7 @@ static vm_fault_t wp_pfn_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		vmf->flags |= FAULT_FLAG_MKWRITE;
 		ret = vma->vm_ops->pfn_mkwrite(vmf);
-		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
+		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY))
 			return ret;
 		return finish_mkwrite_fault(vmf);
 	}
@@ -2536,7 +2536,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp || (tmp &
-				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+				       VM_FAULT_RETRY)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
@@ -3601,7 +3602,8 @@ static vm_fault_t do_shared_fault(struct vm_fault *vmf)
 		unlock_page(vmf->page);
 		tmp = do_page_mkwrite(vmf);
 		if (unlikely(!tmp ||
-				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
+				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE |
+					VM_FAULT_RETRY)))) {
 			put_page(vmf->page);
 			return tmp;
 		}
-- 
2.20.1

