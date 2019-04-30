Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24048C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:29:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB33F21707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 15:29:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MRnb5cGV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB33F21707
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EB636B0005; Tue, 30 Apr 2019 11:29:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59CD36B0008; Tue, 30 Apr 2019 11:29:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 463FA6B000A; Tue, 30 Apr 2019 11:29:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7836B0005
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 11:29:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so7273636plh.14
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 08:29:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=uNyMSJdim8LxSLiJagbrvlvheddQhJAPmuptpHe4W9c=;
        b=YodXqio6RAoC6zeCUQs/MekOMmmY/tOtB7Pcu4fa9RQlRHVu4zua4d+B+708sVrCLj
         WXw0MRH/e1YRjc61ORyA4ZJJGboowE+qhNkSr9c686GSVxrHSZItmQmkhlEd6c34cNHa
         X70VqtqxBxO3TtrbYkOXtHD3m3Uf4Kd6V90ZsvJQExBdnVbSDD/+lQMTC5hluhSmfrle
         01EGygM4bO15U+maghgKznBgEkAGTEMu6WHW/patpvcgFYv/O+V9C5Gj4Foz/ByqQICs
         0u7kgY6D82lm+TPmmLeqyGSuZ9dwKeEqva0I4DvhtEZT0u+5a86gkHkxMgV3m12Lffno
         yR7Q==
X-Gm-Message-State: APjAAAVSSYmIRQtrS349bk3CWfV364xs75Ag8kpJ7MnG6y8bjiE0+aWH
	JtXME+hsM9KrOYBl0TTMiN37cD1bu6UmO2cfgpXqcZWo3gNKhTyz8z4tlLf6o+PhHefjhgvTPRh
	dC0B+I6dlIg6wKOFBPmmHj2NdxeMtGM184voHsDQp6xtIjdRnrReccyLOHpRHp+hDSQ==
X-Received: by 2002:a17:902:20c9:: with SMTP id v9mr70067801plg.239.1556638183704;
        Tue, 30 Apr 2019 08:29:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweJ6M2vN5pkUtwtJSjBERR3sZApf989dOvNF2VXAoCQb1Z35MNPwfGLBPC6MWtvDpWfYpl
X-Received: by 2002:a17:902:20c9:: with SMTP id v9mr70067719plg.239.1556638182921;
        Tue, 30 Apr 2019 08:29:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556638182; cv=none;
        d=google.com; s=arc-20160816;
        b=TqaHmrmXRzIt1Rtntl9lnWy6+pYM2PPCfPqEUfWDHpwDJ5V4JwcPJ3i0bw/Atp89+b
         XCgtNFWjUKLorsS7DtsXTbVVwKDCRfdu0I7AKG4cMFUC9ezV8D0NpyO+p1QMx5T76EWj
         ezlMMvWzzTYk3MNxz//CYWGF+cfRJ8PdXDbVeW0xqcdSjOFpFjj7hskxvb0AYaHSZPF0
         38dcGSWszUVx/rfAyEqickty7O4SHSugj+OgawXgdhdf6rH+wOCmi59hivSaAucwWhUt
         vCjmG1yIoLYytVTc8bUmAwxyQO9wiHwDsH4uS077ABzCIP04otwYnjbZJ6/mNw+q3w/J
         v2+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=uNyMSJdim8LxSLiJagbrvlvheddQhJAPmuptpHe4W9c=;
        b=tHF1pf7GspQ+juQQaa1ZFpqZ1Ua4gBLNLMJKkBiQD6ZBaWo7wU6YeWzDG5ax+2YsYQ
         mPHFX72KtGmokV7OAd52qBmrGKg1C6G/c27csGBSkfKSFEYWQdBWREbZw96vzRT+mV2n
         OJUtBG8Xb45Ncv3+qHzZfqY0DBTk+9nuNmlWWw1ioW18DH9/xyJT1yoHL5TxvLh4jDD3
         aPZXwOIdm1oKmTP6W6fLVx6z3cwey0O2iTd7CfFhbjxMxcwk+FqfP4ChBHwY4J6ptQ80
         NHpEFcKAkSowqWolbMhb2JE2YccZ86JtvdLroVzRmxPWBs99OuuA7WhAVLVdQ9jLSd2Q
         iJ5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MRnb5cGV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t69si37562321pfa.7.2019.04.30.08.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 08:29:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MRnb5cGV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Message-Id:Date:Subject:Cc:To:From:
	Sender:Reply-To:MIME-Version:Content-Type:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uNyMSJdim8LxSLiJagbrvlvheddQhJAPmuptpHe4W9c=; b=MRnb5cGVpaCWGLNaOYprY70WE
	9qmjoeeTg1fbaJimKIKzEmbumOvhybxd0giua2qJq+zeWHTwpaiGOD2CNuzzIqNLY92KVt09TOEQ3
	jrxz6Oc5JtOtjAs6Z5H/UPbJ9EQX2OC3KkE6mb6TG64OWYVwjmfXYriLqqMGkz8YodJ7xnexGh5JW
	4gTNt4Oi/xBrC1S6iE8OMmKlIdF4QanMnX2aPTM1l1ITRzcdVQcEGgO4QebjLN32Ezz+w9+bFzfNI
	sZCAlcN9B7w2SNnK2bS3++c3oOqd2/VRqoJOZivriGHFSwuH1e938b4T2XJrv9E971765hHVmWs0J
	7Ci+kKfQw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLUhR-0005jN-LV; Tue, 30 Apr 2019 15:29:41 +0000
From: Matthew Wilcox <willy@infradead.org>
To: zwisler@kernel.org,
	akpm@linux-foundation.org,
	linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH] mm: Delete find_get_entries_tag
Date: Tue, 30 Apr 2019 08:29:29 -0700
Message-Id: <20190430152929.21813-1-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

I removed the only user of this and hadn't noticed it was now unused.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 include/linux/pagemap.h |  3 --
 mm/filemap.c            | 66 -----------------------------------------
 2 files changed, 69 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index bcf909d0de5f..36973264a767 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -360,9 +360,6 @@ static inline unsigned find_get_pages_tag(struct address_space *mapping,
 	return find_get_pages_range_tag(mapping, index, (pgoff_t)-1, tag,
 					nr_pages, pages);
 }
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
-			xa_mark_t tag, unsigned int nr_entries,
-			struct page **entries, pgoff_t *indices);
 
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
diff --git a/mm/filemap.c b/mm/filemap.c
index d78f577baef2..f052ebe95946 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1964,72 +1964,6 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 }
 EXPORT_SYMBOL(find_get_pages_range_tag);
 
-/**
- * find_get_entries_tag - find and return entries that match @tag
- * @mapping:	the address_space to search
- * @start:	the starting page cache index
- * @tag:	the tag index
- * @nr_entries:	the maximum number of entries
- * @entries:	where the resulting entries are placed
- * @indices:	the cache indices corresponding to the entries in @entries
- *
- * Like find_get_entries, except we only return entries which are tagged with
- * @tag.
- *
- * Return: the number of entries which were found.
- */
-unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
-			xa_mark_t tag, unsigned int nr_entries,
-			struct page **entries, pgoff_t *indices)
-{
-	XA_STATE(xas, &mapping->i_pages, start);
-	struct page *page;
-	unsigned int ret = 0;
-
-	if (!nr_entries)
-		return 0;
-
-	rcu_read_lock();
-	xas_for_each_marked(&xas, page, ULONG_MAX, tag) {
-		struct page *head;
-		if (xas_retry(&xas, page))
-			continue;
-		/*
-		 * A shadow entry of a recently evicted page, a swap
-		 * entry from shmem/tmpfs or a DAX entry.  Return it
-		 * without attempting to raise page count.
-		 */
-		if (xa_is_value(page))
-			goto export;
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto retry;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head)
-			goto put_page;
-
-		/* Has the page moved? */
-		if (unlikely(page != xas_reload(&xas)))
-			goto put_page;
-
-export:
-		indices[ret] = xas.xa_index;
-		entries[ret] = page;
-		if (++ret == nr_entries)
-			break;
-		continue;
-put_page:
-		put_page(head);
-retry:
-		xas_reset(&xas);
-	}
-	rcu_read_unlock();
-	return ret;
-}
-EXPORT_SYMBOL(find_get_entries_tag);
-
 /*
  * CD/DVDs are error prone. When a medium error occurs, the driver may fail
  * a _large_ part of the i/o request. Imagine the worst scenario:
-- 
2.20.1

