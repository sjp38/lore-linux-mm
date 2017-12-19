Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64AF06B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 10:01:34 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b11so2285232itj.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:01:34 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id q143si10121031iod.78.2017.12.19.07.01.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 07:01:33 -0800 (PST)
Date: Tue, 19 Dec 2017 09:01:32 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 3/8] mm: Remove misleading alignment claims
In-Reply-To: <20171216164425.8703-4-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1712190900150.16727@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-4-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Sat, 16 Dec 2017, Matthew Wilcox wrote:

> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> The "third double word block" isn't on 32-bit systems.  The layout
> looks like this:

Right true.

> which is 32 bytes on 64-bit, but 20 bytes on 32-bit.  Nobody is trying
> to use the fact that it's double-word aligned today, so just remove the
> misleading claims.

Well there is the rcu field and the lru fields which I thought at some
point would become useful to locklessly update.

But it did not happen

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
