Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 887DE6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 08:03:10 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so81713337wma.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 05:03:10 -0800 (PST)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id bc6si35483459wjb.29.2016.11.08.05.03.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 05:03:09 -0800 (PST)
Received: by mail-wm0-x236.google.com with SMTP id f82so179428130wmf.1
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 05:03:09 -0800 (PST)
Date: Tue, 8 Nov 2016 16:03:07 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Bug in page_cache_tree_delete?
Message-ID: <20161108130307.GA14032@node>
References: <20161108103541.GN32353@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108103541.GN32353@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Nov 08, 2016 at 11:35:41AM +0100, Jan Kara wrote:
> Hi Kirill,
> 
> I've noticed that your commit 83929372f629 (filemap: prepare find and
> delete operations for huge pages) added to page_cache_tree_delete():
> 
> 	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
> 
> Isn't the logic computing 'nr' inverted? I'd expect that if page is
> !PageHuge, we want to delete just one page... OTOH I'm surprised this would
> not blow up anywhere if it was really wrong so maybe I just miss something.

No, that's not bug.

PageHuge() detects hugetlb pages (we probably should rename the helper)
which represented by one entry on radix-tree per huge page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
