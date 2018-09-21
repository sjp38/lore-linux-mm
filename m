Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id E61B48E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:05:59 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id v12-v6so6058157ybe.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:05:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z62-v6sor2875966ybf.35.2018.09.21.12.05.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Sep 2018 12:05:59 -0700 (PDT)
Received: from mail-yw1-f50.google.com (mail-yw1-f50.google.com. [209.85.161.50])
        by smtp.gmail.com with ESMTPSA id r84-v6sm7199291ywe.10.2018.09.21.12.05.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 12:05:56 -0700 (PDT)
Received: by mail-yw1-f50.google.com with SMTP id x83-v6so5611306ywd.4
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:05:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1536874298-23492-1-git-send-email-rick.p.edgecombe@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 21 Sep 2018 12:05:55 -0700
Message-ID: <CAGXu5jKpwGHRJ92q7yCc+y8esdG6orFVOiZGoGMCi1XiY0JBoQ@mail.gmail.com>
Subject: Re: [PATCH v6 0/4] KASLR feature to randomize each loadable module
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, Sep 13, 2018 at 2:31 PM, Rick Edgecombe
<rick.p.edgecombe@intel.com> wrote:
> This is V6 of the "KASLR feature to randomize each loadable module" patchset.
> The purpose is to increase the randomization and also to make the modules
> randomized in relation to each other instead of just the base, so that if one
> module leaks the location of the others can't be inferred.

I'm excited for this! :)

> Rick Edgecombe (4):
>   vmalloc: Add __vmalloc_node_try_addr function
>   x86/modules: Increase randomization for modules
>   vmalloc: Add debugfs modfraginfo
>   Kselftest for module text allocation benchmarking

Yay for self-tests! This is much appreciated.

-Kees

-- 
Kees Cook
Pixel Security
