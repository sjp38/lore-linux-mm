Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 577BC6B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 22:06:33 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id xk3so9852031obc.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 19:06:33 -0800 (PST)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id p66si781276oih.32.2016.02.09.19.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 19:06:32 -0800 (PST)
Received: by mail-ob0-x232.google.com with SMTP id is5so10037182obc.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 19:06:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160209142444.GA391@gmail.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
 <CALCETrWNx=H=u2R+JKM6Dr3oMqeiBSS+hdrYrGT=BJ-JrEyL+w@mail.gmail.com>
 <20160127044036.GR2948@linux.intel.com> <CALCETrXJacX8HB3vahu0AaarE98qkx-wW9tRYQ8nVVbHt=FgzQ@mail.gmail.com>
 <20160129144909.GV2948@linux.intel.com> <20160209142444.GA391@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 9 Feb 2016 19:06:12 -0800
Message-ID: <CALCETrUaoT2ZnQtTgecQL_bsgHNRezcg_oaPnJyajT+WOx_4EQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and track_pfn_remap()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Feb 9, 2016 6:24 AM, "Ingo Molnar" <mingo@kernel.org> wrote:
>
>
> * Matthew Wilcox <willy@linux.intel.com> wrote:
>
> > > I sure hope not.  If vm_page_prot was writable, something was already broken,
> > > because this is the vvar mapping, and the vvar mapping is VM_READ (and not
> > > even VM_MAYREAD).
> >
> > I do beg yor pardon.  I thought you were inserting a readonly page into the
> > middle of a writable mapping.  Instead you're inserting a non-executable page
> > into the middle of a VM_READ | VM_EXEC mapping. Sorry for the confusion.  I
> > should have written:
> >
> > "like your patch ends up mapping the HPET into userspace executable"
> >
> > which is far less exciting.
>
> Btw., a side note, an executable HPET page has its own dangers as well, for
> example because it always changes in value, it can probabilistically represent
> 'sensible' (and dangerous) executable x86 instructions that exploits can return
> to.
>
> So only mapping it readable (which Andy's patch attempts I think) is worthwile.

The whole vma is readable but not executable, so I don't think this
was a problem.  It's also at a randomized address, which helps.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
