Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2077A6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:53:18 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id g81so11842394ioa.14
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:53:18 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id u14si1407347itc.6.2017.12.19.07.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:53:17 -0800 (PST)
Date: Tue, 19 Dec 2017 09:53:16 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 7/8] mm: Document how to use struct page
In-Reply-To: <20171216164425.8703-8-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1712190952470.16727@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-8-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat, 16 Dec 2017, Matthew Wilcox wrote:

> + * If you allocate pages of order > 0, you can use the fields in the struct
> + * page associated with each page, but bear in mind that the pages may have
> + * been inserted individually into the page cache, so you must use the above
> + * three fields in a compatible way for each struct page.

If they are inserted into the page cache then also other fields are
required like the lru one right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
