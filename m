Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFB36B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 15:59:55 -0500 (EST)
Received: by lfcy184 with SMTP id y184so13805488lfc.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:59:54 -0800 (PST)
Received: from mail-lf0-x22c.google.com (mail-lf0-x22c.google.com. [2a00:1450:4010:c07::22c])
        by mx.google.com with ESMTPS id an6si11426312lbc.81.2015.12.11.12.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 12:59:54 -0800 (PST)
Received: by lfcy184 with SMTP id y184so13805317lfc.1
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 12:59:53 -0800 (PST)
Date: Fri, 11 Dec 2015 23:59:52 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] mm: Account anon mappings as RLIMIT_DATA
Message-ID: <20151211205951.GA29551@uranus>
References: <20151211204939.GA2604@uranus>
 <CA+55aFzbBQp-QzWj2k7twuZ7+ESFpzoRPGZVKWkDv04zHCZ3Sg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzbBQp-QzWj2k7twuZ7+ESFpzoRPGZVKWkDv04zHCZ3Sg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Dec 11, 2015 at 12:55:51PM -0800, Linus Torvalds wrote:
> >
> > +static inline int anon_accountable_mapping(struct file *file, vm_flags_t vm_flags)
> > +{
> > +       return !file &&
> > +               (vm_flags & (VM_GROWSDOWN | VM_GROWSUP |
> > +                            VM_SHARED | VM_MAYSHARE)) == 0;
> > +}
> 
> You're duplicating that "is it an anon accountable mapping" logic. I
> think you should move the inline helper function up, and use it in
> vm_stat_account().
> 
> Other than that, I think the patch certainly looks clean and obvious
> enough. But I didn't actually try to *run* it, maybe it ends up not
> working due to something I don't see.

Thank for the note, Linus! I tried to play with it a little bit,
but I need to test it more first. I sent it simply to be sure
that i'm moving in right direction. Once I get reviewed all things
again and test it more deeply, I'll send a new patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
