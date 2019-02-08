Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD7B4C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 04:24:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 795132147C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 04:24:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OrvPN6Rr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 795132147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 144838E0074; Thu,  7 Feb 2019 23:24:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F4D68E0002; Thu,  7 Feb 2019 23:24:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00A9B8E0074; Thu,  7 Feb 2019 23:24:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3D778E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 23:24:53 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so1555164plt.7
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 20:24:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=noboadxw7ctxVc/zb7Z7XXaMe+1BiHZpqiKt9p1zupE=;
        b=pmXudHvbF4o+pYJUiE8JhpnD+qwcrTfX6kDXn40+Hl95io+o+hPixiLoqRofAf6Gzj
         HH/kEa+rhnXyJOVxyk32xfm16Fz9pQZBO/nvQ0DDnoHZo6FPNhuIUV5o6uH4NMHwxROp
         PltdGOvQ0njncD3Ax4UNDlxk9jYyVQbPkJee9l/cEkZ4eNySxUQZ8+nMZqe7ZT0FB3rD
         pg1e4c38n5n0VgOwxsdZ9nMkC7HpOBlyYWvBJ6VJMp2RSzvPw+7ZkJbmWFeUcg++AJO+
         rmaM1Sw5oRVOt2dqGbd6Sfp+Q+C3YnSN4HFvLAVNDbtzpDfZqJOkgDuqvdb/r180+EeJ
         hiNg==
X-Gm-Message-State: AHQUAuZRJ4NHqxPxm6yWqLHb0yYlvoiUG7iYCZ979BQ4QAEYMuY8o6hD
	s1Ib21SxPsbPFwC7CU54Vhk/vfuVz+nrDV50e+vlheY5zHh6TyZEQu3iJ2RLB9XbZyy0SR0ezZX
	shuzDGb3iYGVdOtCD9xEfz+mbopK4yv+ayzqZoaYwepgJTn1e4cGjM3TKvy+a5eLgEw==
X-Received: by 2002:a17:902:1022:: with SMTP id b31mr20352289pla.141.1549599893248;
        Thu, 07 Feb 2019 20:24:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaAE8bZyxkWIiKmGFAWsahYg2LfN1Rhwkj4/pDmma4Womw0NFDQMOQfw9f290GrDt9ZmXcP
X-Received: by 2002:a17:902:1022:: with SMTP id b31mr20352242pla.141.1549599892534;
        Thu, 07 Feb 2019 20:24:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549599892; cv=none;
        d=google.com; s=arc-20160816;
        b=WBZDpLpomFfkd9vlwAvboXoGmC7/iQTt6PAVOt3g/AgUerKpO6RiGr7N8RsbRLls6c
         vnCVn6eh+MxSzHesvtgQP5ytFq01xkTXHhg1ElxsHGWZH1QCSz5hvv+PtHcHqsWw5bqE
         3glB+g18abVA7Ov3Yu2kWujDkSe3z7iYOSE5Re6PZSsd2gtcyc6W5/Q2W5gA7J3q7ECy
         g5ygj4gtmCVDPGmC33z3RSqTUtxL2UmHws5ppgwRZvLlqodshfwGSS1yNSCV044sLc0I
         RVj5U8CMNl4LUGGiLQkT/XfoVTcCodOa5TMbhiXMVxlPHIivOe6ybNDoxlK4y4vb5q6z
         HO9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=noboadxw7ctxVc/zb7Z7XXaMe+1BiHZpqiKt9p1zupE=;
        b=zI48LQnqeKwMOr2XbZypRcKGqs6VJr7Bd9BRKc8j21hJ7H7L+Yf0Piuera4IxGl87K
         M5Ly4L279QTLQSxA6n61RW26c/3Lf9pww69DEOOjB3K0+w8FfXOQE3gBdI0BLfaM3+YT
         AwxVAVgncTaj7L6OYFGZmwjmmw68zGWmv3/IU7omhSjhjETzH0zXIH2b7zusyFfUp4NX
         SU/b39TcwaMmL7CzXshn85CrFDiHn0HKL4m1Wj+D3xDOlxgxwK7hiqiNS6qUFZzImNDf
         YvHzNNWj2IhmJZFCqYRikpmMC1ymlK3C5U8MU06jFR0Xw+wyc1unRejKacEx0o7DIIVT
         wXWA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OrvPN6Rr;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g21si1087864pgl.114.2019.02.07.20.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 20:24:51 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OrvPN6Rr;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=noboadxw7ctxVc/zb7Z7XXaMe+1BiHZpqiKt9p1zupE=; b=OrvPN6RrhGeIQDHv48xmpifKL
	LGlns3tGZE0+zhHmlcLAT4HRy8cIhud75ze1UDRFCyqdj+zvD324AlMcSYv5m4zSnJLJWEbLAkzma
	QDVHlr9Fg8ZQtc9+iSypOttL8Oxx8FKWaSem8IVC3qzKMAq0lqxz7dj+fHuQvmasfYl3HVsCO6RnA
	4cCDOSExnrQCefkkAh+o/syoGSfAGuHMpc+OfY8oaSD/TBSniRW87JVKeGmkh/Kt94GdcfuFHmnkK
	5N/spFta5kOVevN2BJCLuwaJw2ZAiWO5y45Tl9m6ZMBibYgJKbitcIzJJIssag/Cb75w1yZ3p8y4Q
	o1Md/gUsw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1grxia-0001lm-Db; Fri, 08 Feb 2019 04:24:48 +0000
Date: Thu, 7 Feb 2019 20:24:48 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: lsf-pc@lists.linux-foundation.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Non standard size THP
Message-ID: <20190208042448.GB21860@bombadil.infradead.org>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 07:43:57AM +0530, Anshuman Khandual wrote:
> How non-standard huge pages can be supported for THP
> 
> 	- THP starts recognizing non standard huge page (exported by arch) like HPAGE_CONT_(PMD|PTE)_SIZE
> 	- THP starts operating for either on HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE or HPAGE_CONT_PTE_SIZE
> 	- set_pmd_at() only recognizes HPAGE_PMD_SIZE hence replace set_pmd_at() with set_huge_pmd_at()
> 	- set_huge_pmd_at() could differentiate between HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE
> 	- In case for HPAGE_CONT_PTE_SIZE extend page table walker till PTE level
> 	- Use set_huge_pte_at() which can operate on multiple contiguous PTE bits

I think your proposed solution reflects thinking like a hardware person
rather than like a software person.  Or maybe like an MM person rather
than a FS person.  I see the same problem with Kirill's solutions ;-)

Perhaps you don't realise that using larger pages when appropriate
would also benefit filesystems as well as CPUs.  You didn't include
linux-fsdevel on this submission, so that's a plausible explanation.

The XArray currently supports arbitrary power-of-two-naturally-aligned
page sizes, and conveniently so does the page allocator [1].  The problem
is that various bits of the MM have a very fixed mindset that pages are
PTE, PMD or PUD in size.

We should enhance routines like vmf_insert_page() to handle
arbitrary sized pages rather than having separate vmf_insert_pfn()
and vmf_insert_pfn_pmd().  We probably need to enhance the set_pxx_at()
API to pass in an order, rather than explicitly naming pte/pmd/pud/...

First, though, we need to actually get arbitrary sized pages handled
correctly in the page cache.  So if anyone's interested in talking about
this, but hasn't been reviewing or commenting on the patches I've been
sending to make this happen, I'm going to seriously question their actual
commitment to wanting this to happen, rather than wanting a nice holiday
in Puerto Rico.

Sorry to be so blunt about this, but I've only had review from Kirill,
which makes me think that nobody else actually cares about getting
this fixed.

[1] Support for arbitrary sized and aligned entries is in progress for
the XArray, but I don't think there's any appetite for changing the buddy
allocator to let us allocate "pages" that are an arbitrary extent in size.

