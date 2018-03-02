Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEDCE6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 15:48:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y20so5852549pfm.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 12:48:25 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d67si5437696pfe.49.2018.03.02.12.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Mar 2018 12:48:24 -0800 (PST)
Date: Fri, 2 Mar 2018 12:48:08 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Message-ID: <20180302204808.GA671@bombadil.infradead.org>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <20180228183349.GA16336@bombadil.infradead.org>
 <C9D0E3BA-3AB9-4F0E-BDA5-32378E440986@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C9D0E3BA-3AB9-4F0E-BDA5-32378E440986@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Fri, Mar 02, 2018 at 11:30:28PM +0300, Ilya Smith wrote:
> This is a really good question. Lets think we choose address with random-length 
> guard hole. This length is limited by some configuration as you described. For 
> instance let it be 1MB. Now according to current implementation, we still may 
> fill this gap with small allocations with size less than 1MB. Attacker will 
> going to build attack base on this predictable behaviour - he jus need to spray 
> with 1 MB chunks (or less, with some expectation). This attack harder but not 
> impossible.

Ah, I didn't mean that.  I was thinking that we can change the
implementation to reserve 1-N pages after the end of the mapping.
So you can't map anything else in there, and any load/store into that
region will segfault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
