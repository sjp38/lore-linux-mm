Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 552B96B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 05:56:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k199so15254119lfg.16
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 02:56:30 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id c63si2971050lfe.242.2017.03.31.02.56.28
        for <linux-mm@kvack.org>;
        Fri, 31 Mar 2017 02:56:28 -0700 (PDT)
Date: Fri, 31 Mar 2017 11:56:17 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: crash under qemu, bisected to f2a6a7050109 ("x86: Convert the
 rest of the code to support p4d_t")
Message-ID: <20170331095617.5d5sxrk54uqzqfgf@pd.tnic>
References: <20170331070653.GA8716@Red>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170331070653.GA8716@Red>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Cc: kirill.shutemov@linux.intel.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 31, 2017 at 09:06:53AM +0200, Corentin Labbe wrote:
> hello
> 
> Since linux-next-20170329, my qemu virtual machine crash with:
> [    1.409213] Freeing unused kernel memory: 688K
> [    1.414790] Freeing unused kernel memory: 1920K
> [    1.415581] BUG: unable to handle kernel paging request at ffffc753f000f000
> [    1.416808] IP: ptdump_walk_pgd_level_core+0x2d1/0x430

https://lkml.kernel.org/r/20170328185522.5akqgfh4niqi3ptf@pd.tnic

Reportedly, latest tip/master should be fixed but I haven't tried it
yet.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
