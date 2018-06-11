Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7306B000D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:25:23 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id s133-v6so19512200qke.21
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:25:23 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id d25-v6si8307800qtc.279.2018.06.11.10.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 10:25:22 -0700 (PDT)
Date: Mon, 11 Jun 2018 17:25:21 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Distinguishing VMalloc pages
In-Reply-To: <20180611121129.GB12912@bombadil.infradead.org>
Message-ID: <01000163efe179fe-d6270c58-eaba-482f-a6bd-334667250ef7-000000@email.amazonses.com>
References: <20180611121129.GB12912@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Mon, 11 Jun 2018, Matthew Wilcox wrote:

>
> I think we all like the idea of being able to look at a page [1] and
> determine what it's used for.  We have two places that we already look:
>
> PageSlab
> page_type

Since we already have PageSlab: Is it possible to use that flag
differently so that it is maybe something like PageTyped(xx)? I think
there may be some bits available somewhere if PageSlab( is set and these
typed pages usually are not on the lru. So if its untyped the page is on
LRU otherwise the type can be identified somehow?
