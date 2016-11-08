Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4296B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 05:35:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so79002479wma.2
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 02:35:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si34719146wjz.64.2016.11.08.02.35.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 02:35:44 -0800 (PST)
Date: Tue, 8 Nov 2016 11:35:41 +0100
From: Jan Kara <jack@suse.cz>
Subject: Bug in page_cache_tree_delete?
Message-ID: <20161108103541.GN32353@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Kirill,

I've noticed that your commit 83929372f629 (filemap: prepare find and
delete operations for huge pages) added to page_cache_tree_delete():

	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);

Isn't the logic computing 'nr' inverted? I'd expect that if page is
!PageHuge, we want to delete just one page... OTOH I'm surprised this would
not blow up anywhere if it was really wrong so maybe I just miss something.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
