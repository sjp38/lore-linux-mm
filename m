Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD006B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 13:03:11 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id d77so11943011oig.7
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:03:11 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id 1si1769836oih.206.2017.06.28.10.03.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 10:03:10 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id h134so39423511iof.2
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:03:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170620040403.GA610@zzz.localdomain>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-22-git-send-email-keescook@chromium.org> <20170620040403.GA610@zzz.localdomain>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 28 Jun 2017 10:03:09 -0700
Message-ID: <CAGXu5jLcZO3XHBd7i7Gnww4vwRpH10m2FvczEecnC_ars-N+Ow@mail.gmail.com>
Subject: Re: [kernel-hardening] [PATCH 21/23] usercopy: Restrict non-usercopy
 caches to size 0
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, David Windsor <dave@nullcore.net>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 19, 2017 at 9:04 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> Hi David + Kees,
>
> On Mon, Jun 19, 2017 at 04:36:35PM -0700, Kees Cook wrote:
>> With all known usercopied cache whitelists now defined in the kernel, switch
>> the default usercopy region of kmem_cache_create() to size 0. Any new caches
>> with usercopy regions will now need to use kmem_cache_create_usercopy()
>> instead of kmem_cache_create().
>>
>
> While I'd certainly like to see the caches be whitelisted, it needs to be made
> very clear that it's being done (the cover letter for this series falsely claims
> that kmem_cache_create() is unchanged) and what the consequences are.  Is there

Well, in the first patch it is semantically unchanged: calls to
kmem_cache_create() after the first patch whitelist the entire cache
object. Only from this patch on does it change behavior to no longer
whitelist the object.

> any specific plan for identifying caches that were missed?  If it's expected for

The plan for finding caches needing whitelisting is mainly code audit
and operational testing. Encountering it is quite loud in that it BUGs
the kernel during the hardened usercopy checks.

> people to just fix them as they are found, then they need to be helped a little
> --- at the very least by putting a big comment above report_usercopy() that
> explains the possible reasons why the error might have triggered and what to do
> about it.

That sounds reasonable. It should have a comment even for the existing
protections.

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
