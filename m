Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C4A976B0276
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:43:03 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w141so1229282wme.1
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:43:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l13sor7813925edj.1.2017.12.19.05.43.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 05:43:02 -0800 (PST)
Date: Tue, 19 Dec 2017 16:43:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
Message-ID: <20171219134300.wyyatkub3x4nm5s3@node.shutemov.name>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-8-willy@infradead.org>
 <20171219095927.GF2787@dhcp22.suse.cz>
 <20171219130703.GC13680@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219130703.GC13680@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 05:07:03AM -0800, Matthew Wilcox wrote:
> I'm also teaching myself more about ReStructuredText, and to that end I've
> started to document all these pages side-by-side in a table.

Maybe we should get the table to the point where we can generate C description
of the struct and stop writing in C manually? :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
