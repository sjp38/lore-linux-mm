Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9855F828E5
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 17:22:35 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id zm5so151935902pac.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 14:22:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 79si2376936pfm.61.2016.04.04.14.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 14:22:34 -0700 (PDT)
Date: Mon, 4 Apr 2016 14:22:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mm: filemap: only do access activations on reads
Message-Id: <20160404142233.cfdea284b8107768fb359efd@linux-foundation.org>
In-Reply-To: <1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
References: <1459790018-6630-1-git-send-email-hannes@cmpxchg.org>
	<1459790018-6630-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andres Freund <andres@anarazel.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon,  4 Apr 2016 13:13:37 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Andres Freund observed that his database workload is struggling with
> the transaction journal creating pressure on frequently read pages.
> 
> Access patterns like transaction journals frequently write the same
> pages over and over, but in the majority of cases those pages are
> never read back. There are no caching benefits to be had for those
> pages, so activating them and having them put pressure on pages that
> do benefit from caching is a bad choice.

Read-after-write is a pretty common pattern: temporary files for
example.  What are the opportunities for regressions here?

Did you consider providing userspace with a way to hint "this file is
probably write-then-not-read"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
