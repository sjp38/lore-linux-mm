Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 932B46B002B
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 05:51:36 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 17so4333532wrm.10
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 02:51:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o26sor1245125edi.29.2018.02.09.02.51.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Feb 2018 02:51:35 -0800 (PST)
Date: Fri, 9 Feb 2018 13:51:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Split page_type out from _map_count
Message-ID: <20180209105132.hhkjoijini3f74fz@node.shutemov.name>
References: <20180207213047.6148-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207213047.6148-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Feb 07, 2018 at 01:30:47PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> We're already using a union of many fields here, so stop abusing the
> _map_count and make page_type its own field.  That implies renaming some
> of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
> bring back the PG_buddy, PG_balloon and PG_kmemcg names.

Sounds reasonable to me.

> Also, the special values don't need to be (and probably shouldn't be) powers
> of two, so renumber them to just start at -128.

Are you sure about this? Is it guarantee that we would not need in the
future PG_buddy|PG_kmemcg for instance?

I guess we may want to make it a bitfield. In negative space it's kinda
interesting. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
