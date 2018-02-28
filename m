Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id F1DAB6B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 13:33:59 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id q5-v6so1851019pll.17
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 10:33:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z3si1325828pgr.744.2018.02.28.10.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Feb 2018 10:33:56 -0800 (PST)
Date: Wed, 28 Feb 2018 10:33:49 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Message-ID: <20180228183349.GA16336@bombadil.infradead.org>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, Feb 28, 2018 at 08:13:00PM +0300, Ilya Smith wrote:
> > It would be worth spelling out the "not recommended" bit some more
> > too: this fragments the mmap space, which has some serious issues on
> > smaller address spaces if you get into a situation where you cannot
> > allocate a hole large enough between the other allocations.
> > 
> 
> Ia??m agree, that's the point.

Would it be worth randomising the address returned just ever so slightly?
ie instead of allocating exactly the next address, put in a guard hole
of (configurable, by default maybe) 1-15 pages?  Is that enough extra
entropy to foil an interesting number of attacks, or do we need the full
randomise-the-address-space approach in order to be useful?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
