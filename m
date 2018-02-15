Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 481EF6B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:23:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 189so107690pge.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:23:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f5-v6si4709677plj.659.2018.02.15.08.23.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Feb 2018 08:23:05 -0800 (PST)
Date: Thu, 15 Feb 2018 08:23:03 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180215162303.GC12360@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <alpine.DEB.2.20.1802141354530.28235@nuc-kabylake>
 <20180214201400.GD20627@bombadil.infradead.org>
 <alpine.DEB.2.20.1802150953080.1902@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802150953080.1902@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Thu, Feb 15, 2018 at 09:55:11AM -0600, Christopher Lameter wrote:
> On Wed, 14 Feb 2018, Matthew Wilcox wrote:
> 
> > > Uppercase like the similar KMEM_CACHE related macros in
> > > include/linux/slab.h?>
> >
> > Do you think that would look better in the users?  Compare:
> 
> Does looking matter? I thought we had the convention that macros are
> uppercase. There are some tricks going on with the struct. Uppercase shows
> that something special is going on.

  12) Macros, Enums and RTL
  -------------------------

  Names of macros defining constants and labels in enums are capitalized.

  .. code-block:: c

          #define CONSTANT 0x12345

  Enums are preferred when defining several related constants.

  CAPITALIZED macro names are appreciated but macros resembling functions
  may be named in lower case.

I dunno.  Yes, there's macro trickery going on here, but it certainly
resembles a function.  It doesn't fail any of the rules laid out in that
chapter of coding-style about unacceptable uses of macros.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
