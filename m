Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC436C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:33:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C973218D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:33:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Y8cK7K/R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C973218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0215C8E0015; Tue, 12 Feb 2019 03:33:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F13738E0007; Tue, 12 Feb 2019 03:33:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5D78E0015; Tue, 12 Feb 2019 03:33:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 995578E0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:33:37 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b8so1800973pfe.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:33:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oxpVHbVB7l2HeJxotboIxFL5Ps+MVnJBLdvQHDnnO30=;
        b=AU11lWVgDFAGaojqbo2eDcvsxc9+dw/o0P414KFeBOeGUI615HR37guthlFA4Cniiv
         Grxu8lBdhKawEx9UYEWG+rVF9MzDcl6KSd7sd55cMc05SHem85LFIqrguqjH5xOgQXBe
         go0T4u8y2N3FeNYi6RKiZfsc+/k0/OnnQQ13updm9+Hl6eSwSi2svmIxS8EypIO1w+Ng
         dQSqFVopFm6fxmoV6SvntfLNdJAjBrmzM0xWTpPaRmJ84rHSnzzwPrRg/mT2hFmXTd8w
         9ER/4y3kkfdMYMhltD+QsjurPpSzKpvTKvxxuES9lMsu/CxYMG2OfqvszktYPBL5jOtr
         KNgA==
X-Gm-Message-State: AHQUAuZg5uLqZblrTHjujmoV44yFSiFrKOXItFbYxBuU+8xWV7EVYL4i
	5pN2WEKXj7Rp3eXmcO28oQ2Hsf7g3U8UdmslKQXgIJxttTKCSsoxawHhcbjwa0zBac+u1NrXHsL
	4eAFMJnfqUkFd4mzpU13Jrr48Vv5BLrxOYJ5MFrRnUHvQ3l5yEq3pu4BY8jEQ9NEBaVOF7sxgHz
	T1vDiHf20wfvrAjIN9OnaaJJdZOdzmFxtaS4hrQmc1kwUymYJPZN+53bEw6SjvJ68FOKrVUdfEo
	NeVk22oI1sB20Deunh0H+VxOF46AGuGdVZz7IBSDBtONnKzvg+xhYj+AVg2R+jhuENAcPelew/u
	Td0nnRU+oD2+RBLl2Z1Alk8Gz7NQpiRPb6HDNqsLW8BfhYtMTa0h2t7c5jnoKKhDn3XTwP2OPbt
	9
X-Received: by 2002:a17:902:1486:: with SMTP id k6mr2908483pla.49.1549960417306;
        Tue, 12 Feb 2019 00:33:37 -0800 (PST)
X-Received: by 2002:a17:902:1486:: with SMTP id k6mr2908441pla.49.1549960416568;
        Tue, 12 Feb 2019 00:33:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549960416; cv=none;
        d=google.com; s=arc-20160816;
        b=AVCFHF6FlZ30sOWZt0mguoubJcIkWEYq2TJwA0D3hN6Z7e4MfBNT3/piCactMz4gPe
         u5oqva4LLuZ8xD3oVcZjhwfDm4mqpqD5qBXmPcru3OQRpiF2jVvR6nxWRoDT/TlBhJVS
         0qlZVJgoJPZLKtMvP7e7x5z3kHQv5oO04nG/+G+7KhofwAGBCyESAwCue5xSZOYpkBa3
         0kmIWoxKB+c88aGoojYG2VqARpy6VonGhLqMUU7gNACvmZtJrhMHEWxe3EVKV8eWaiXO
         q4Ud90OnxKzONMiLV6mBBH77Neo4c5I9R5DUy2UNz8CQZXPJBVoVsohItT/Sf609C3Ys
         m6WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oxpVHbVB7l2HeJxotboIxFL5Ps+MVnJBLdvQHDnnO30=;
        b=J6BmLPLu1soLMLrsfN0TqQrkpEEYHlKPR4QXMPXmpghYUBJn3Oxyd4HF+RdC/MXs0c
         tb/bMcHCx+2tvCpIeMeZxPUFatccQc5eyeXIs/+yJYNkZ7plyTMnfT4zy6WpLmH/ObgK
         Rj/yTAg7xIt1C5nq/r0JsmERt9S4Mz878uOZ37tbRj2srXxAqwyMowUVDlQOaubiXmm2
         o0sHocSgSqaShwznPoFb/ZtDUGkzdpqnMbLVXbZkRNwserDtLzTelFj0wCb6aZPVLHpJ
         XpxIiOnVUmDBRdnYADFUriHS6tXsWH+nJbUvHhO8sAVoka33+6UHa5m7u4a5QVi30du2
         Wj9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="Y8cK7K/R";
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e188sor17803378pgc.19.2019.02.12.00.33.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 00:33:36 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="Y8cK7K/R";
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=oxpVHbVB7l2HeJxotboIxFL5Ps+MVnJBLdvQHDnnO30=;
        b=Y8cK7K/R2zLDx3Bj2hQ1RX1SrUyGn1tV3BMXqVkN7ZWspvQcFuU1f0tbxoCYCOvGvi
         9Q3sgeiVATtMmeWvM5tqo031SgpHatHXiWK03QEeMhdGC0LQ1JU/T1wMiv5tG9/3XRvl
         DKHjgREpR9BD0oJKzXLCzjXLpgqmCmh8QxeHJlZIDGUBJk3YSdgyQ9jtf+gdSv3wXqe9
         WmkcfXjmasP/z2wQ13SyZZYiHOL7bbu4WS63HuY07QwrxM481yfgT8IVoucnFbx162Kn
         4lllmzDp/SVmHMxQoknKrRwFIA6xK4TBliABDpkcChISx1CiC9dUeRy4Xwz3yzRQzZ08
         Zwdg==
X-Google-Smtp-Source: AHgI3IY6lJA+Q5N5XsipGp9xj2gavVKReVrIo/vQTtw7S8oAQ6vQpHX+ohnN8tUL2spN5xLM270LWQ==
X-Received: by 2002:a63:f552:: with SMTP id e18mr2565316pgk.239.1549960416064;
        Tue, 12 Feb 2019 00:33:36 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.41])
        by smtp.gmail.com with ESMTPSA id l87sm23337013pfj.35.2019.02.12.00.33.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:33:35 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id EB8A0300573; Tue, 12 Feb 2019 11:33:31 +0300 (+03)
Date: Tue, 12 Feb 2019 11:33:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: lsf-pc@lists.linux-foundation.org,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [LSF/MM TOPIC] Non standard size THP
Message-ID: <20190212083331.dtch7xubjxlmz5tf@kshutemo-mobl1>
References: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dcb0b2cf-ba5c-e6ef-0b05-c6006227b6a9@arm.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 07:43:57AM +0530, Anshuman Khandual wrote:
> Hello,
> 
> THP is currently supported for
> 
> - PMD level pages (anon and file)
> - PUD level pages (file - DAX file system)
> 
> THP is a single entry mapping at standard page table levels (either PMD or PUD)
> 
> But architectures like ARM64 supports non-standard page table level huge pages
> with contiguous bits.
> 
> - These are created as multiple entries at either PTE or PMD level
> - These multiple entries carry pages which are physically contiguous
> - A special PTE bit (PTE_CONT) is set indicating single entry to be contiguous
> 
> These multiple contiguous entries create a huge page size which is different
> than standard PMD/PUD level but they provide benefits of huge memory like
> less number of faults, bigger TLB coverage, less TLB miss etc.
> 
> Currently they are used as HugeTLB pages because
> 
> 	- HugeTLB page sizes is carried in the VMA
> 	- Page table walker can operate on multiple PTE or PMD entries given its size in VMA
> 	- Irrespective of HugeTLB page size its operated with set_huge_pte_at() at any level
> 	- set_huge_pte_at() is arch specific which knows how to encode multiple consecutive entries
> 	
> But not as THP huge pages because
> 
> 	- THP size is not encoded any where like VMA
> 	- Page table walker expects it to be either at PUD (HPAGE_PUD_SIZE) or at PMD (HPAGE_PMD_SIZE)
> 	- Page table operates directly with set_pmd_at() or set_pud_at()
> 	- Direct faulted or promoted huge pages is verified with [pmd|pud]_trans_huge()
> 
> How non-standard huge pages can be supported for THP
> 
> 	- THP starts recognizing non standard huge page (exported by arch) like HPAGE_CONT_(PMD|PTE)_SIZE
> 	- THP starts operating for either on HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE or HPAGE_CONT_PTE_SIZE
> 	- set_pmd_at() only recognizes HPAGE_PMD_SIZE hence replace set_pmd_at() with set_huge_pmd_at()
> 	- set_huge_pmd_at() could differentiate between HPAGE_PMD_SIZE or HPAGE_CONT_PMD_SIZE
> 	- In case for HPAGE_CONT_PTE_SIZE extend page table walker till PTE level
> 	- Use set_huge_pte_at() which can operate on multiple contiguous PTE bits

You only listed trivial things. All tricky stuff is what make THP
transparent.

To consider it seriously we need to understand what it means for
split_huge_p?d()/split_huge_page()? How khugepaged will deal with this?

In particular, I'm worry to expose (to user or CPU) page table state in
the middle of conversion (huge->small or small->huge). Handling this on
page table level provides a level atomicity that you will not have.

Honestly, I'm very skeptical about the idea. It took a lot of time to
stabilize THP for singe page size, equal to PMD page table, but this looks
like a new can of worms. :P

It *might* be possible to support it for DAX, but beyond that...

-- 
 Kirill A. Shutemov

