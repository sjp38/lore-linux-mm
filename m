Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB0E8E00CE
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:53:13 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id h10so11145131plk.12
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:53:13 -0800 (PST)
Date: Tue, 11 Dec 2018 10:53:11 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
Message-ID: <20181211185311.GJ6830@bombadil.infradead.org>
References: <20181128183531.5139-1-willy@infradead.org>
 <09e3d156-66fc-ca17-efac-63f080a27a1d@kernel.dk>
 <20181211184553.GH6830@bombadil.infradead.org>
 <75267003-9407-101f-33ee-685e345a2c8a@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75267003-9407-101f-33ee-685e345a2c8a@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, fsdevel <linux-fsdevel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, Dec 11, 2018 at 11:46:53AM -0700, Jens Axboe wrote:
> On 12/11/18 11:45 AM, Matthew Wilcox wrote:
> > I think we need the rcu read lock here to prevent ctx from being freed
> > under us by free_ioctx().
> 
> Then that begs the question, how about __xa_load() that is already called
> under RCU read lock?

I've been considering adding it to the API, yes.  I was under the
impression that nested rcu_read_lock() calls were not expensive, even
with CONFIG_PREEMPT.
