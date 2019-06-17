Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DFA4C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1E8F2085A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:29:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1E8F2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9034B8E0004; Mon, 17 Jun 2019 15:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88C2A8E0001; Mon, 17 Jun 2019 15:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77B978E0004; Mon, 17 Jun 2019 15:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53A768E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:29:27 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p43so10160377qtk.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=/xlNlelotM+Dvc+xUSx9X17ASwHKHoVnlctg4TDQCb8=;
        b=TYjcEAZHMAAnPTDQRZElZnsaqDOqwNbu1QZyYExfD7Y7zm88/RY3NKYVk98RV1piNB
         krzPPDrmW7LJyEM2qgOrWXn7vQ6OWW5Dd2e7A+OUI1LmZd0bIKrBKq7Wc1I/z0ZaU4ng
         ucjyJjsG9mOhkGnq6GIhLc+uTP2l+Ra/uGOzBX4pFWqYYFbxzTLwTprLEbIvQoMFFk2U
         5t85JTtiV3lya52bLtwiNVkm4ZiZdkMkbezFn/rtbQgbJFggQ+3zfsBQW/lVVaJasVqC
         n8dPjhhHSQxhVL/RCGaQKHzozkn4L9V0zrHVYAjS1KUNiMiqhHhRNzhI5gaB7xwb483A
         lRnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAVG9DIAOaUH5dRtH93UkSvlA9smzzQJMqrQtfLHUJEMD8o6qguP
	WxRX4yFgl/acrZG0sOB+udJ2RsT/pclV0Kh+Grfk03j10cKVPVMPANOu6gavA0ospiUwTqIL432
	R3h0hElheQybmMUC9gydyFS+ezoPvnoTZ8BF039RMfJovZvUI1ClUM5YZ35pjqtk=
X-Received: by 2002:a0c:ba0b:: with SMTP id w11mr23027690qvf.71.1560799767125;
        Mon, 17 Jun 2019 12:29:27 -0700 (PDT)
X-Received: by 2002:a0c:ba0b:: with SMTP id w11mr23027646qvf.71.1560799766437;
        Mon, 17 Jun 2019 12:29:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560799766; cv=none;
        d=google.com; s=arc-20160816;
        b=zgb3aeQEyqHDjsyWaOQWo7L0pEqQ8Ci/XWBrYpUlfHywK+h0xOiyBYF+NMIa9tpySO
         y2TCWCLPPomo8U879J+JDxfb2ZOhNlKIIYIqxa/X/R7O6jSOOKGpKt806e4wLT0Oj6SP
         q5PUP9IPERJjpGWRQhySO74AQLjmom/OTr03HIJf3S0p93F6fzxirgrP8HG+rer/khqF
         iFwiNevtdappAL5fF3Lw7Br0L/kqdpavl/fvWobuKsWsXOWl14Hb1GryDagbEG1YfzsT
         kP5+rdOh4gY+StfFFNgnwQM/LZa9pTU4eDlTSkgQPZQS1rPiGl/df/XcCb9JZwI8k2iZ
         fP6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=/xlNlelotM+Dvc+xUSx9X17ASwHKHoVnlctg4TDQCb8=;
        b=UrTk8fYn5eI6mwmU01LS3qMBJZcihoUY0xzM3B7qqWSSICce0+C7JSQfM6iCJxO6H5
         i64gMjUGEfg4wY90b8DVk7CV8/efr8xunkbo+xqfTS1B2znZpBnFujZi9tvgnxJAbcNE
         q9o4sxdNE6aBwIH7mf0r4RO+IruSRxXefYFnLiAqtjPzHm0FbonZpspUMHAEDYwCAKsE
         2dGgMlAdH0FuHjzeNJgULywOjCpCAo7pp/QrQ2jGXRv6n1S85yQRYb8TOmJlcre3LZsS
         f6+QSahUmJlr10NA6f7s9QNUWOTTyVAPooCf2l319WOQywX5RkFQoHErxPLA9jI+0iL0
         2KRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s14sor17664658qta.47.2019.06.17.12.29.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 12:29:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqzmfEEp6gZuCeDUa3GncclqO8Dliciq18czTA1lJjjPkfklni0CHo+I/ASPntOHr7eDK1ToeB1Yu+l+Zozbcl4=
X-Received: by 2002:ac8:3485:: with SMTP id w5mr18630643qtb.142.1560799765930;
 Mon, 17 Jun 2019 12:29:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190617121427.77565-1-arnd@arndb.de> <20190617141244.5x22nrylw7hodafp@pc636>
 <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
 <CAK8P3a0pnEnzfMkCi7Nb97-nG4vnAj7fOepfOaW0OtywP8TLpw@mail.gmail.com> <20190617165730.5l7z47n3vg73q7mp@pc636>
In-Reply-To: <20190617165730.5l7z47n3vg73q7mp@pc636>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 17 Jun 2019 21:29:08 +0200
Message-ID: <CAK8P3a1Ab2MVVgSh4EW0Yef_BsxcRbkxarknMzV7tOA+s79qsA@mail.gmail.com>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in pcpu_get_vm_areas
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, 
	Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Roman Penyaev <rpenyaev@suse.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:57 PM Uladzislau Rezki <urezki@gmail.com> wrote:
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index a9213fc3802d..5b7e50de008b 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -915,7 +915,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >  {
> >         struct vmap_area *lva;
> >
> > -       if (type == FL_FIT_TYPE) {
> > +       switch (type) {
> > +       case FL_FIT_TYPE:
> >                 /*
> >                  * No need to split VA, it fully fits.
> >                  *
> > @@ -925,7 +926,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >                  */
> >                 unlink_va(va, &free_vmap_area_root);
> >                 kmem_cache_free(vmap_area_cachep, va);
> > -       } else if (type == LE_FIT_TYPE) {
> > +               break;
> > +       case LE_FIT_TYPE:
> >                 /*
> >                  * Split left edge of fit VA.
> >                  *
> > @@ -934,7 +936,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >                  * |-------|-------|
> >                  */
> >                 va->va_start += size;
> > -       } else if (type == RE_FIT_TYPE) {
> > +               break;
> > +       case RE_FIT_TYPE:
> >                 /*
> >                  * Split right edge of fit VA.
> >                  *
> > @@ -943,7 +946,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >                  * |-------|-------|
> >                  */
> >                 va->va_end = nva_start_addr;
> > -       } else if (type == NE_FIT_TYPE) {
> > +               break;
> > +       case NE_FIT_TYPE:
> >                 /*
> >                  * Split no edge of fit VA.
> >                  *
> > @@ -980,7 +984,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
> >                  * Shrink this VA to remaining size.
> >                  */
> >                 va->va_start = nva_start_addr + size;
> > -       } else {
> > +               break;
> > +       default:
> >                 return -1;
> >         }
> >
> To me it is not clear how it would solve the warning. It sounds like
> your GCC after this change is able to keep track of that variable
> probably because of less generated code. But i am not sure about
> other versions. For example i have:
>
> gcc version 6.3.0 20170516 (Debian 6.3.0-18+deb9u1)
>
> and it totally OK, i.e. it does not emit any related warning.

To provide some background here, I'm doing randconfig tests, and
this warning might be one that only shows up with a specific combination
of options that add complexity to the build.

I do run into a lot -Wmaybe-uninitialized warnings, and most of the time
can figure out to change the code to be more readable by both
humans and compilers in a way that shuts up the warning. The
underlying algorithm in the compiler is NP-complete, so it can't
ever get it right 100%, but it is a valuable warning in general.

Using switch/case makes it easier for the compiler because it
seems to turn this into a single conditional instead of a set of
conditions. It also seems to be the much more common style
in the kernel.

> Another thing is that, if we add mode code there or change the function
> prototype, we might run into the same warning. Therefore i proposed that
> we just set the variable to NULL, i.e. Initialize it.

The problem with adding explicit NULL initializations is that this is
more likely to hide actual bugs if the code changes again, and the
compiler no longer notices the problem, so I try to avoid ever
initializing a variable to something that would cause a runtime
bug in place of a compile time warning later.

       Arnd

