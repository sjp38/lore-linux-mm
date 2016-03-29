Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B57546B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 17:29:16 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id zm5so23548903pac.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 14:29:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n7si928244pap.214.2016.03.29.14.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 14:29:15 -0700 (PDT)
Date: Tue, 29 Mar 2016 14:29:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Refactor find_get_pages() & friends
Message-Id: <20160329142911.f2b069c8af06f649b86ec993@linux-foundation.org>
In-Reply-To: <20160309011643.GA23179@kmo-pixel>
References: <20160309011643.GA23179@kmo-pixel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 8 Mar 2016 16:16:43 -0900 Kent Overstreet <kent.overstreet@gmail.com> wrote:

> Collapse redundant implementations of various gang pagecache lookup - this is
> also prep work for pagecache iterator work

Patch looks nice.  Unfortunately filemap.c has changed rather a lot
since 4.5.  Can you please redo the patch some time?

And a more informative changelog would be appropriate, although it's
all pretty obvious.  I don't know what "pagecache iterator work" is
and I doubt if many other readers do either, so some illumination there
wouldn't hurt.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
