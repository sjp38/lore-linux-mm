Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4546B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:37:14 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so599803qen.19
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 09:37:14 -0800 (PST)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTP id w9si8201298qad.44.2013.12.12.09.37.10
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 09:37:13 -0800 (PST)
Date: Thu, 12 Dec 2013 17:37:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [RFC] mm: slab: separate slab_page from 'struct page'
In-Reply-To: <52A793D0.4020306@sr71.net>
Message-ID: <00000142e7e23135-20f346b1-a880-47b0-946c-122323669ec1-000000@email.amazonses.com>
References: <20131210204641.3CB515AE@viggo.jf.intel.com> <00000142de5634af-f92870a7-efe2-45cd-b50d-a6fbdf3b353c-000000@email.amazonses.com> <52A78B55.8050500@sr71.net> <00000142de866123-cf1406b5-b7a3-4688-b46f-80e338a622a1-000000@email.amazonses.com>
 <52A793D0.4020306@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On Tue, 10 Dec 2013, Dave Hansen wrote:

> See? *EVERYTHING* is overridden by at least one of the sl?b allocators
> except ->flags.  In other words, there *ARE* no relationships when it
> comes to the sl?bs, except for page->flags.

Slab objects can be used for I/O and then the page fields become
important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
