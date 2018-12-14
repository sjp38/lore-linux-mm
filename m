Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5730D8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:24:56 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so4451074pgq.12
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:24:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s123si4614714pfb.274.2018.12.14.10.24.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 10:24:55 -0800 (PST)
Date: Fri, 14 Dec 2018 10:24:52 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC 1/4] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
Message-ID: <20181214182452.GD10600@bombadil.infradead.org>
References: <20181214180720.32040-1-guro@fb.com>
 <20181214180720.32040-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214180720.32040-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

On Fri, Dec 14, 2018 at 10:07:17AM -0800, Roman Gushchin wrote:
> __vunmap() calls find_vm_area() twice without an obvious reason:
> first directly to get the area pointer, second indirectly by calling
> remove_vm_area(), which is again searching for the area.
> 
> To remove this redundancy, let's split remove_vm_area() into
> __remove_vm_area(struct vmap_area *), which performs the actual area
> removal, and remove_vm_area(const void *addr) wrapper, which can
> be used everywhere, where it has been used before.
> 
> On my test setup, I've got up to 12% speed up on vfree()'ing 1000000
> of 4-pages vmalloc blocks.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Matthew Wilcox <willy@infradead.org>
