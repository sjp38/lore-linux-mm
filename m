Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2FBD56B0006
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 21:58:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v8so1834506pgs.9
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 18:58:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j14si1764730pfn.150.2018.03.07.18.58.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 18:58:23 -0800 (PST)
Date: Wed, 7 Mar 2018 18:58:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180308025812.GA9082@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803072212160.2814@hadrien>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Wed, Mar 07, 2018 at 10:18:21PM +0100, Julia Lawall wrote:
> > Otherwise, yes, please. We could build a coccinelle rule for
> > additional replacements...
> 
> A potential semantic patch and the changes it generates are attached
> below.  Himanshu Jha helped with its development.  Working on this
> uncovered one bug, where the allocated array is too large, because the
> size provided for it was a structure size, but actually only pointers to
> that structure were to be stored in it.

This is cool!  Thanks for doing the coccinelle patch!  Diffstat:

 50 files changed, 81 insertions(+), 124 deletions(-)

I find that pretty compelling.  I'll repost the kvmalloc_struct patch
imminently.
