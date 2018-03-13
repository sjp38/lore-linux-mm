Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6666B0022
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:35:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id f16so497351wre.0
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:35:49 -0700 (PDT)
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id s18si512584wrs.426.2018.03.13.11.35.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:35:48 -0700 (PDT)
Date: Tue, 13 Mar 2018 19:35:44 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
In-Reply-To: <20180313183220.GA21538@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1803131935160.3117@hadrien>
References: <20180214182618.14627-1-willy@infradead.org> <20180214182618.14627-3-willy@infradead.org> <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com> <alpine.DEB.2.20.1803072212160.2814@hadrien> <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien> <20180308230512.GD29073@bombadil.infradead.org> <alpine.DEB.2.20.1803131818550.3117@hadrien> <20180313183220.GA21538@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>



On Tue, 13 Mar 2018, Matthew Wilcox wrote:

> On Tue, Mar 13, 2018 at 06:19:51PM +0100, Julia Lawall wrote:
> > On Thu, 8 Mar 2018, Matthew Wilcox wrote:
> > > On Thu, Mar 08, 2018 at 07:24:47AM +0100, Julia Lawall wrote:
> > > > Thanks.  So it's OK to replace kmalloc and kzalloc, even though they
> > > > didn't previously consider vmalloc and even though kmalloc doesn't zero?
> > >
> > > We'll also need to replace the corresponding places where those structs
> > > are freed with kvfree().  Can coccinelle handle that too?
> >
> > Is the use of vmalloc a necessary part of the design?  Or could there be a
> > non vmalloc versions for call sites that are already ok with that?
>
> We can also add kmalloc_struct() along with kmalloc_ab_c that won't fall
> back to vmalloc but just return NULL.

It could be safer than being sure to find all of the relevant kfrees.

julia
