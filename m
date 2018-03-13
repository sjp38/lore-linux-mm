Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF416B0022
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:32:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j12so227910pff.18
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:32:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bc5-v6si510118plb.506.2018.03.13.11.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 11:32:27 -0700 (PDT)
Date: Tue, 13 Mar 2018 11:32:20 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180313183220.GA21538@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien>
 <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien>
 <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803131818550.3117@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Tue, Mar 13, 2018 at 06:19:51PM +0100, Julia Lawall wrote:
> On Thu, 8 Mar 2018, Matthew Wilcox wrote:
> > On Thu, Mar 08, 2018 at 07:24:47AM +0100, Julia Lawall wrote:
> > > Thanks.  So it's OK to replace kmalloc and kzalloc, even though they
> > > didn't previously consider vmalloc and even though kmalloc doesn't zero?
> >
> > We'll also need to replace the corresponding places where those structs
> > are freed with kvfree().  Can coccinelle handle that too?
> 
> Is the use of vmalloc a necessary part of the design?  Or could there be a
> non vmalloc versions for call sites that are already ok with that?

We can also add kmalloc_struct() along with kmalloc_ab_c that won't fall
back to vmalloc but just return NULL.
