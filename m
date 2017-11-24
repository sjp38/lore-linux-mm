Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 740056B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 14:56:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l19so23046329pgo.4
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 11:56:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u39si18559057pgn.488.2017.11.24.11.56.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 11:56:17 -0800 (PST)
Date: Fri, 24 Nov 2017 11:56:15 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: XArray documentation
Message-ID: <20171124195615.GA3665@bombadil.infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
 <3543098.x2GeNdvaH7@merkaba>
 <20171124170307.GA681@bombadil.infradead.org>
 <2627399.jpLCoM7KBo@merkaba>
 <CALvZod7dZuHrCavL985j1MqeJ_bUT8Fnz5UhTwHzF_+vcwJ6dA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7dZuHrCavL985j1MqeJ_bUT8Fnz5UhTwHzF_+vcwJ6dA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Martin Steigerwald <martin@lichtvoll.de>, linux-fsdevel@vger.kernel.org, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Nov 24, 2017 at 11:48:49AM -0800, Shakeel Butt wrote:
> Adding on to Martin's questions. Basically what is the motivation
> behind it? It seems like a replacement for radix tree, so, it would be
> good to write why radix tree was not good enough or which use cases
> radix tree could not solve. Also how XArray solves those
> issues/use-cases? And if you know which scenarios or use-cases where
> XArray will not be an optimal solution.

I strongly disagree that there should be any mention of the radix tree
in this document.  In the Glorious Future, there will be no more radix
tree and so talking about it will only confuse people (because Linux's
radix tree is not in fact a radix tree).

Talking about why the radix tree isn't good enough is for the cover letter.
I did it quite well here:

https://lwn.net/Articles/715948/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
