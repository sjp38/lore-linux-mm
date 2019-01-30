Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB45BC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B709720989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:45:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B709720989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD0F68E0004; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7EAC8E0002; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 899538E0006; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23EE78E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:45:16 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c18so9155539edt.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:45:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=n9EewSWBpIrjWW0Ewb2hQwGri96Bkj/XJ3FPiJDZfXg=;
        b=U4xlMvKqPTRmdp09G+FNwhZM/EJk+GqFieh51TkdmyEJJ5txY+sSMtDn49qvBc0TFk
         xyp7oo/rXRmyoRsFkS2AMOJ2bH3DxNPkNu2II8r/bPPg/DYn8zW4BIHX1ZJ73yLOZ8pj
         TvjVe7whtpe/NJ/gqTJp6/QLSxOosnS1ftuIF0W2Q0MKijXzLeLRmaH6qlU2AJm2Uvbq
         GIyG7FDkffQUtp2JSbbzNlxeGO+l2mMGiTPEx2n2dHXIDyMEaqubpQsuEAYY4dJ7k9Ic
         b1Vjz0QyCU1HpWMLISD72SoPX5oIKpf1soySufQkSOTKUxnfZka+EGtBFaQSUTlOzMII
         w0Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuaYtPj9Ne345VizHid8j5Y0UEi4qw3p4r6AIN/FGRsfzudonxeB
	H9jVcvmKh3mgsqbzMNnu79LbEvsjCg3J9n4GIlUqdqQKewdxHzJ7rdpFK0WwevcZqx1gvBtc1GR
	b3gqfM0b5efxdPdL61nwr7sss1r9ORIKarfbGx69IB7axkkIwFztRjKrq2lddhSMMpQ==
X-Received: by 2002:a17:906:2596:: with SMTP id m22mr5813807ejb.249.1548852315465;
        Wed, 30 Jan 2019 04:45:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZl+DZxEGQyOZ7ZWVf8rEoyS6xXO83UfSaqfmQmQlFjdMtQLm70XSYJsW97scoplHNDwJb0
X-Received: by 2002:a17:906:2596:: with SMTP id m22mr5813731ejb.249.1548852314110;
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548852314; cv=none;
        d=google.com; s=arc-20160816;
        b=QrT/LA77rnNJiZVDv+STYpmiPjFdZXP33r74s1d2RBbJ63yFyrZYJNAGtfF8bIrpoo
         xqwYcJqZcw9tmcsQpUbYFNi7kriJGJuCwHwSUtBuPxHQJqZpnFvmLWaxYq+QExcDDFPW
         j5R+K3ef9zF8oxu8NuBHH+n1E4nrGvX/MLaiTXAKPQFar/X2Cu1OOyXY4nr9YTkfUyYg
         w8jQqbDEH9fsbp8gr7qNDlxkkhkj/ic5DJdWeMymXe5hoymXy0lidmCRXMwCgtrvHaN4
         9bsI8v/n+BpWdqaKtUKZ3jSMNU1tZz8cwpLiKMwNynB8/rWWpbChsZZWBOiybcqoFZ5G
         SthA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=n9EewSWBpIrjWW0Ewb2hQwGri96Bkj/XJ3FPiJDZfXg=;
        b=qlTRIxZk7AsuTuP5U/FyD1JhqVUXmsgH4RRWjnsdfAx2aQIIoPGemjrWjLv3WHpQi4
         kGtk7Bnmn9cFyX+kPkQjJZR5x1jik+kLJgC+fKBAjtqzdTgWzoqlxZjK2K42tR7F7Jrv
         oXvlg1Wk9LE5BswhxMCGtWzRWCOGT3D6w65BXx67/ZKpOAm0HTBTa1LBxI8vxmubtzkR
         64M2HM/cRBV+4kzYV9Wqclnp7gjq/no+PnGXat7myHPo+KZDZE0N/vnnkXHwnmbB7ba6
         /nPTDnQun27as1eaGdAFwpfP99c2FtMxFHC5m9hRbCPuM8zFExJs/6EEOzMMdk9S8fMM
         D5OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g11si969510edf.155.2019.01.30.04.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 04:45:14 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4CEA0B020;
	Wed, 30 Jan 2019 12:45:13 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	Jann Horn <jannh@google.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>,
	Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>,
	Vlastimil Babka <vbabka@suse.cz>,
	Jiri Kosina <jikos@kernel.org>
Subject: [PATCH 1/3] mm/mincore: make mincore() more conservative
Date: Wed, 30 Jan 2019 13:44:18 +0100
Message-Id: <20190130124420.1834-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190130124420.1834-1-vbabka@suse.cz>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jiri Kosina <jkosina@suse.cz>

The semantics of what mincore() considers to be resident is not completely
clear, but Linux has always (since 2.3.52, which is when mincore() was
initially done) treated it as "page is available in page cache".

That's potentially a problem, as that [in]directly exposes meta-information
about pagecache / memory mapping state even about memory not strictly belonging
to the process executing the syscall, opening possibilities for sidechannel
attacks.

Change the semantics of mincore() so that it only reveals pagecache information
for non-anonymous mappings that belog to files that the calling process could
(if it tried to) successfully open for writing.

Originally-by: Linus Torvalds <torvalds@linux-foundation.org>
Originally-by: Dominique Martinet <asmadeus@codewreck.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Kevin Easton <kevin@guarana.org>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Cyril Hrubis <chrubis@suse.cz>
Cc: Tejun Heo <tj@kernel.org>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Daniel Gruss <daniel@gruss.cc>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mincore.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..747a4907a3ac 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -169,6 +169,14 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
+static inline bool can_do_mincore(struct vm_area_struct *vma)
+{
+	return vma_is_anonymous(vma) ||
+		(vma->vm_file &&
+			(inode_owner_or_capable(file_inode(vma->vm_file))
+			 || inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0));
+}
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -189,8 +197,13 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-	mincore_walk.mm = vma->vm_mm;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
+	if (!can_do_mincore(vma)) {
+		unsigned long pages = (end - addr) >> PAGE_SHIFT;
+		memset(vec, 1, pages);
+		return pages;
+	}
+	mincore_walk.mm = vma->vm_mm;
 	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
 		return err;
-- 
2.20.1

