Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E71E16B0011
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:04:18 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id k19so9030635ita.8
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:04:18 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 80si1940990ioo.242.2018.02.09.11.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 11:04:18 -0800 (PST)
Date: Fri, 9 Feb 2018 13:04:16 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: Split page_type out from _map_count
In-Reply-To: <7c5414ce-fece-b908-bebc-22fa15fc783c@intel.com>
Message-ID: <alpine.DEB.2.20.1802091300220.2923@nuc-kabylake>
References: <20180207213047.6148-1-willy@infradead.org> <20180209105132.hhkjoijini3f74fz@node.shutemov.name> <20180209134942.GB16666@bombadil.infradead.org> <20180209152848.GF16666@bombadil.infradead.org> <7c5414ce-fece-b908-bebc-22fa15fc783c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, 9 Feb 2018, Dave Hansen wrote:

> Are there any straightforward rules that we can enforce here?  For
> instance, if you are using "page_type", you can never have PG_lru set.
>
> Not that we have done this at all for 'struct page' historically, it
> would be really convenient to have a clear definition for when
> "page_type" is valid vs. "_mapcount".

Well in general we would like to be able to enforce uses depending on
the contents of other fields in struct page. That would require compiler
support I guess?

What we could do is write a struct page validator that checks contents
using some macros? Could be added to the usual places where we check
consistency and could also be used for a global sweep over struct pages
for validation.

SLUB can do that for metadata. If we could express consistency rules for
objects in general then it may even have a wider applicability.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
