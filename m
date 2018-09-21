Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45A2A8E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 14:46:44 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id l2-v6so6303537ywb.6
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:46:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z3-v6sor3057847ybn.99.2018.09.21.11.46.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 11:46:43 -0700 (PDT)
Received: from mail-yw1-f44.google.com (mail-yw1-f44.google.com. [209.85.161.44])
        by smtp.gmail.com with ESMTPSA id n187-v6sm15974830ywn.76.2018.09.21.11.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 11:46:40 -0700 (PDT)
Received: by mail-yw1-f44.google.com with SMTP id 14-v6so5584374ywe.2
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:46:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1536874298-23492-2-git-send-email-rick.p.edgecombe@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com> <1536874298-23492-2-git-send-email-rick.p.edgecombe@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 21 Sep 2018 11:46:39 -0700
Message-ID: <CAGXu5jKTiPioDjC7rrjN+fG=ZK8mdQ542GwEJW6Fa7GUA8x2uQ@mail.gmail.com>
Subject: Re: [PATCH v6 1/4] vmalloc: Add __vmalloc_node_try_addr function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

On Thu, Sep 13, 2018 at 2:31 PM, Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
> Create __vmalloc_node_try_addr function that tries to allocate at a specific
> address and supports caller specified behavior for whether any lazy purging
> happens if there is a collision.
>
> This new function draws from the __vmalloc_node_range implementation. Attempts
> to merge the two into a single allocator resulted in logic that was difficult
> to follow, so they are left separate.
>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

I'd love to get some more mm folks to look this over too.

-Kees

-- 
Kees Cook
Pixel Security
