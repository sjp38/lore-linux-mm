Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id ADE526B0073
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 16:07:43 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id i17so4507379qcy.9
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:07:43 -0800 (PST)
Received: from a9-42.smtp-out.amazonses.com (a9-42.smtp-out.amazonses.com. [54.240.9.42])
        by mx.google.com with ESMTP id j7si13181062qab.119.2013.12.10.13.07.41
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 13:07:42 -0800 (PST)
Date: Tue, 10 Dec 2013 21:07:40 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [RFC] mm: slab: separate slab_page from 'struct page'
In-Reply-To: <20131210204641.3CB515AE@viggo.jf.intel.com>
Message-ID: <00000142de5634af-f92870a7-efe2-45cd-b50d-a6fbdf3b353c-000000@email.amazonses.com>
References: <20131210204641.3CB515AE@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On Tue, 10 Dec 2013, Dave Hansen wrote:

> At least for slab, this doesn't turn out to be too big of a deal:
> it's only 8 casts.  slub looks like it'll be a bit more work, but
> still manageable.

The single page struct definitions makes it easy to see how a certain
field is being used in various subsystems. If you add a field then you
can see other use cases in other subsystems. If you happen to call
them then you know that there is trouble afoot.

Also if you screw up the sizes then you screw up the page struct for
everything and its very evident that a problem exists.

How do you ensure that the sizes and the locations of the fields in
multiple page structs stay consistent?

As far as I can tell we are trying to put everything into one page struct
to keep track of the uses of various fields and to allow a reference for
newcomes to the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
