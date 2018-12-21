Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC8EE8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:46:08 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 68so5866504pfr.6
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 11:46:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s38si14389410pga.38.2018.12.21.11.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 11:46:07 -0800 (PST)
Date: Fri, 21 Dec 2018 11:45:47 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 03/12] __wr_after_init: generic header
Message-ID: <20181221194547.GI10600@bombadil.infradead.org>
References: <20181219213338.26619-1-igor.stoppa@huawei.com>
 <20181219213338.26619-4-igor.stoppa@huawei.com>
 <8474D7CA-E5FF-40B1-9428-855854CDDB5F@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8474D7CA-E5FF-40B1-9428-855854CDDB5F@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Igor Stoppa <igor.stoppa@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2018 at 11:38:16AM -0800, Nadav Amit wrote:
> > On Dec 19, 2018, at 1:33 PM, Igor Stoppa <igor.stoppa@gmail.com> wrote:
> > 
> > +static inline void *wr_memset(void *p, int c, __kernel_size_t len)
> > +{
> > +	return __wr_op((unsigned long)p, (unsigned long)c, len, WR_MEMSET);
> > +}
> 
> What do you think about doing something like:
> 
> #define __wr          __attribute__((address_space(5)))
> 
> And then make all the pointers to write-rarely memory to use this attribute?
> It might require more changes to the code, but can prevent bugs.

I like this idea.  It was something I was considering suggesting.
