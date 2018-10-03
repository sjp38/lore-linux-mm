Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B1EBB6B0273
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:39:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 43-v6so5566070ple.19
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:39:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 3-v6si1681623pln.324.2018.10.03.06.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Oct 2018 06:39:08 -0700 (PDT)
Date: Wed, 3 Oct 2018 06:38:56 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH v4 09/27] x86/mm: Change _PAGE_DIRTY to _PAGE_DIRTY_HW
Message-ID: <20181003133856.GA24782@bombadil.infradead.org>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-10-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-10-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:33AM -0700, Yu-cheng Yu wrote:
> We are going to create _PAGE_DIRTY_SW for non-hardware, memory
> management purposes.  Rename _PAGE_DIRTY to _PAGE_DIRTY_HW and
> _PAGE_BIT_DIRTY to _PAGE_BIT_DIRTY_HW to make these PTE dirty
> bits more clear.  There are no functional changes in this
> patch.

I would like there to be some documentation in this patchset which
explains the difference between PAGE_SOFT_DIRTY and PAGE_DIRTY_SW.

Also, is it really necessary to rename PAGE_DIRTY?  It feels like a
lot of churn.
