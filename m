Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44AE56B1FCB
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 08:12:58 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t22so1357317plo.10
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 05:12:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id d12-v6si45956906pla.24.2018.11.20.05.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Nov 2018 05:12:56 -0800 (PST)
Date: Tue, 20 Nov 2018 05:12:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: fix swap offset when replacing shmem page
Message-ID: <20181120131247.GA3065@bombadil.infradead.org>
References: <20181119004719.156411-1-yuzhao@google.com>
 <20181119010924.177177-1-yuzhao@google.com>
 <alpine.LSU.2.11.1811191343280.17359@eggly.anvils>
 <20181120012950.GA94981@google.com>
 <alpine.LSU.2.11.1811192057490.2185@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811192057490.2185@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Yu Zhao <yuzhao@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 19, 2018 at 09:07:27PM -0800, Hugh Dickins wrote:
> I don't much like my original use of the name "swap_index", when it was
> not the index in a swapfile (though it was the index in the radix tree);
> but it will become a correct name with your patch.
> 
> Though Matthew Wilcox seems to want us to avoid saying "radix tree"...

Naming is hard ... but the Linux radix tree looks almost nothing like
a classic computer science radix tree.  If you try to reconcile our
implementation with the wikipedia article on radix trees, you'll get
very confused.

A lot of places where we were saying 'radix tree' in comments should
really have said 'page cache'.  So is this a swap cache index?  I'm
not really familiar enough with the swapping code to say.
