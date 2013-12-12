Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 06E3D6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 14:32:24 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so719412yho.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 11:32:24 -0800 (PST)
Received: from a9-70.smtp-out.amazonses.com (a9-70.smtp-out.amazonses.com. [54.240.9.70])
        by mx.google.com with ESMTP id kc8si19602239qeb.103.2013.12.12.11.32.23
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 11:32:24 -0800 (PST)
Date: Thu, 12 Dec 2013 19:32:22 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 1/3] mm: slab: create helpers for slab ->freelist
 pointer
In-Reply-To: <20131211224023.5F39AC88@viggo.jf.intel.com>
Message-ID: <00000142e84bacf0-e6eeb332-e66b-48c6-95d8-d4a7cba0f24d-000000@email.amazonses.com>
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com> <20131211224023.5F39AC88@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On Wed, 11 Dec 2013, Dave Hansen wrote:

>
> We have a need to move the ->freelist data around 'struct page'
> in order to keep a cmpxchg aligned.  First step is to add an
> accessor function which we will hook in to in the next patch.
>
> I'm not super-happy with how this looks.  It's a bit ugly, but it
> does work.  I'm open to some better suggestions for how to do
> this.


I think the mapping field is not used by SLUB and its ok to use since SLAB
uses it for its memory pointer. Maybe you can use that to get the correct
alignment? Do an and of address used for the cmpxchg with 0xffff
.. ff0 to ensure proper aligment (the resulting address may overlap
the mapping field).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
