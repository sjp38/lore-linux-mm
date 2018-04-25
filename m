Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDD16B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:13:06 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e12-v6so18192726qtp.17
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:13:06 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id g127si2701309qkc.358.2018.04.25.12.13.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 12:13:04 -0700 (PDT)
Date: Wed, 25 Apr 2018 14:13:03 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC] Scale slub page allocations with memory size
In-Reply-To: <20180425044752.GB15974@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804251410100.31137@nuc-kabylake>
References: <20180425044752.GB15974@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Tue, 24 Apr 2018, Matthew Wilcox wrote:

> From: Matthew Wilcox <mawilcox@microsoft.com>
>
> With larger memory sizes, it's more important to avoid external
> fragmentation than reduce memory usage.

If you do that then the higher order pages that we will then be using will
be exhausted faster. I think we need a generic fix to be able to preserve
higher order pages first.

Dave Hansen and I thought about a 2M basepage configuration?

Something between 4k and 2M would be better but then the hardware wont
support that and given that we can have terabytes in a server this may
be feasable now.

Or make order 0 be 64k page like on ARM 64 and Power and then handle
multiple ptes like the implementation years ago by Hugh.
