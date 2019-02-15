Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24291C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 20:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF485222A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 20:21:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rEIVnWW2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF485222A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032998E0002; Fri, 15 Feb 2019 15:21:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F271D8E0001; Fri, 15 Feb 2019 15:20:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3D2A8E0002; Fri, 15 Feb 2019 15:20:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A32238E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 15:20:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id ay11so7630657plb.20
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:20:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=t4kh6gL7Nt9+3Mr1Ov9ssDsZXZ4VLPAcQPbRxG5XoQE=;
        b=Zc7X0E4HQCs2dd3++VImm5ZgNsKjykTqyN906AyglMdwapbuYTtQczXFRibBce6Mmc
         g9+mMwwWdbGo6zg/fP8rwdeX6D5cq+CyKnesJLjnE97pUpHOS3AAZUlnbzBqpdQyLEBG
         86w61CmrQMex+dPOnHTpLfvZ41K1ymGjwxVgL7nZfe158m9zWzGqOSlswLmFuePjA0MT
         /xF60wByuZpIYjrgVMsKBMooY1CcRTRpDP5/b9Ub5YyH66dCpqOWdxrQnVa79bn9BJg1
         dzkEMUHi2pIT4riNBf3+CXtbJfmXp4QuncLEDpFK5D5h9tmaSbtGjGfk0FPXkq7llwjW
         qc/Q==
X-Gm-Message-State: AHQUAuZLFACgF2IqOmaYsKbnRVrFTU9ehHusVdgISfGQ4eu+MfgUDNgy
	Q9qTKF0oB6X7vIGy6KgbbPnfLygw66qQLVKc7kBcYOH9MmCwOOvS0nX4h+JBrkPisd/8c4AWWyt
	or9i0jFUkdnU+/PR+hDMCD7BIsg47iiTRuNdreDZA7LGa45I/R7enZBHg/HTsRNwUBA==
X-Received: by 2002:a17:902:241:: with SMTP id 59mr11854672plc.72.1550262059175;
        Fri, 15 Feb 2019 12:20:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZyrt1fZFenljH4DQAXq3Cv7tpkwl55KKJpzKTuie0dWS7dFGlutxNkW75JSSQCA0OoG5sB
X-Received: by 2002:a17:902:241:: with SMTP id 59mr11854619plc.72.1550262058392;
        Fri, 15 Feb 2019 12:20:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550262058; cv=none;
        d=google.com; s=arc-20160816;
        b=eYFbzK5UqjjZBXw3Vx0+GDLebwMXKBN2FcltEP2cP93atDNo+gjfC1OoJ39EhMNSfa
         cCw1ULmAJ0CQk1YUvadvJkgf+YJwA1pKlY4Ym4rFcbhvEtw5xrZW9WC1rAX34pbAQzRT
         U45h7uxtproHrYkwfSJcvcqceufctRRkN49RFmLu/Z9pFUafx8s6IiPE+1X4NCy+E5uS
         WgXmd1jtiExUfWaeniMV0GgkZUMXMz52oi3df7oYOk4oq+rcfxqqHtRBtU+zjyuF4xAf
         9to058Z2LXfF+8Pcn0+gb+8zTb2zlyk43pOVi8JBpNDp8I52VYpY8B67FqZivtMzNCgl
         NJnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=t4kh6gL7Nt9+3Mr1Ov9ssDsZXZ4VLPAcQPbRxG5XoQE=;
        b=lCfET4erd09+6+EbXaDOS6wpH0Kh80oEZ7U/ilBXanCfgUYEpMYiOpynOL09OW97XO
         oVGfzwiHGSNdB/4ZWnntX7WNHE9xg+vJpQyuc9qJgXrRlAk3w9OxUJu/10xvrgV+rrnN
         jukxiImr88ftjUMNxkSePOuKIsxkgx3SF/stDVAUmseYnmQtsvQ3x1Qm6fLQ6CV/YFZj
         hiB5LzOfyPNAcoLPOCd+N0Quv5+KvHZ5rAn7d3MmApZaHtLUnrl8APBNcYH7PRJVr8Xt
         Q1NNxu7mUTKDMynHFaXsO6JlrzMDstSpU9Nu+q9esD2cON7hPD9B7RdKAFNNmKgtEt1B
         BFPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rEIVnWW2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k188si6597890pgc.246.2019.02.15.12.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 12:20:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rEIVnWW2;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=t4kh6gL7Nt9+3Mr1Ov9ssDsZXZ4VLPAcQPbRxG5XoQE=; b=rEIVnWW2VmDLAFvnYVAJS9d0A
	WYO74VFpVSuuTJjJTmuLb2Pd0os80RVkoZMhJ1+8pMVhnDNhDN2XsYrNcgBIf45rUowaVCLh9uyc7
	qIf0clGtvkiiCE3+56fIKS+l/L+9u+yNjbr7G8/U0n7gjdwtL7ZTaKwfQH0KKImdKB4Rzk1+sIAwG
	r/hYCUPKEXeL+VFFtvEaSKQCHvBT+/8CUCESKqWK4DtMd/75Scf/P6mnDaVy1KD318xj3lea9Vt8j
	l33nVqqjeTYkHev8OLJ+tPdu7Np5wHsWriuXqOouo2l7yDC4ACjZyCVseuMXb4X9G0dQgTdPuOUud
	3nftqlg1w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gujyj-0008Pk-7C; Fri, 15 Feb 2019 20:20:57 +0000
Date: Fri, 15 Feb 2019 12:20:57 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190215202056.GK12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
 <20190214224115.4edwl7x72abztajb@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214224115.4edwl7x72abztajb@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:41:15AM +0300, Kirill A. Shutemov wrote:
>   - __delete_from_swap_cache() will blow up on
> 
> 	VM_BUG_ON_PAGE(entry != page + i, entry);

Right.

@@ -167,7 +167,7 @@ void __delete_from_swap_cache(struct page *page, swp_entry_t entry)
 
        for (i = 0; i < nr; i++) {
                void *entry = xas_store(&xas, NULL);
-               VM_BUG_ON_PAGE(entry != page + i, entry);
+               VM_BUG_ON_PAGE(entry != page, entry);
                set_page_private(page + i, 0);
                xas_next(&xas);
        }

