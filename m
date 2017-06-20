Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E4E346B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:51:20 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e63so624363iod.11
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:51:20 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id b79si75541iob.40.2017.06.20.15.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 15:51:20 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id t87so482008ioe.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:51:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1497931790.11009.1.camel@gmail.com>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-24-git-send-email-keescook@chromium.org> <1497931790.11009.1.camel@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 20 Jun 2017 15:51:18 -0700
Message-ID: <CAGXu5jJckTkYqWRv5AUv=Ks8_477xuZn=RB+0tiXC=sGDe1QEA@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 23/23] mm: Allow slab_nomerge to be set
 at build time
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 19, 2017 at 9:09 PM, Daniel Micay <danielmicay@gmail.com> wrote:
> On Mon, 2017-06-19 at 16:36 -0700, Kees Cook wrote:
>> Some hardened environments want to build kernels with slab_nomerge
>> already set (so that they do not depend on remembering to set the
>> kernel
>> command line option). This is desired to reduce the risk of kernel
>> heap
>> overflows being able to overwrite objects from merged caches,
>> increasing
>> the difficulty of these attacks. By keeping caches unmerged, these
>> kinds
>> of exploits can usually only damage objects in the same cache (though
>> the
>> risk to metadata exploitation is unchanged).
>
> It also further fragments the ability to influence slab cache layout,
> i.e. primitives to do things like filling up slabs to set things up for
> an exploit might not be able to deal with the target slabs anymore. It
> doesn't need to be mentioned but it's something to think about too. In
> theory, disabling merging can make it *easier* to get the right layout
> too if there was some annoyance that's now split away. It's definitely a
> lot more good than bad for security though, but allocator changes have
> subtle impact on exploitation. This can make caches more deterministic.

Good point about changes to heap grooming; I'll adjust the commit log.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
