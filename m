Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5E96B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 08:51:35 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so11298533wme.4
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 05:51:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kq9si35622617wjb.151.2016.11.08.05.51.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 05:51:34 -0800 (PST)
Date: Tue, 8 Nov 2016 14:51:32 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Bug in page_cache_tree_delete?
Message-ID: <20161108135132.GS32353@quack2.suse.cz>
References: <20161108103541.GN32353@quack2.suse.cz>
 <20161108130307.GA14032@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108130307.GA14032@node>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue 08-11-16 16:03:07, Kirill A. Shutemov wrote:
> On Tue, Nov 08, 2016 at 11:35:41AM +0100, Jan Kara wrote:
> > Hi Kirill,
> > 
> > I've noticed that your commit 83929372f629 (filemap: prepare find and
> > delete operations for huge pages) added to page_cache_tree_delete():
> > 
> > 	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
> > 
> > Isn't the logic computing 'nr' inverted? I'd expect that if page is
> > !PageHuge, we want to delete just one page... OTOH I'm surprised this would
> > not blow up anywhere if it was really wrong so maybe I just miss something.
> 
> No, that's not bug.
> 
> PageHuge() detects hugetlb pages (we probably should rename the helper)
> which represented by one entry on radix-tree per huge page.

Ah, right. Thanks for explanation! Maybe that line would deserve a comment?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
