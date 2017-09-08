Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A46396B0335
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 11:44:25 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c195so3216964itb.5
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 08:44:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 30sor518921ioq.117.2017.09.08.08.44.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Sep 2017 08:44:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170908075519.GD4957@infradead.org>
References: <20170907173609.22696-1-tycho@docker.com> <20170907173609.22696-11-tycho@docker.com>
 <20170908075519.GD4957@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 8 Sep 2017 08:44:22 -0700
Message-ID: <CAGXu5jL8wRg2307wKkGf9ASZHTtYZMwPzn10100-Mfmx9p2=Fg@mail.gmail.com>
Subject: Re: [PATCH v6 10/11] mm: add a user_virt_to_phys symbol
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "x86@kernel.org" <x86@kernel.org>

On Fri, Sep 8, 2017 at 12:55 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Sep 07, 2017 at 11:36:08AM -0600, Tycho Andersen wrote:
>> We need someting like this for testing XPFO. Since it's architecture
>> specific, putting it in the test code is slightly awkward, so let's make it
>> an arch-specific symbol and export it for use in LKDTM.
>
> We really should not add an export for this.
>
> I think you'll want to just open code it in your test module.

Isn't that going to be fragile? Why not an export?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
