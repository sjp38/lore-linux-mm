Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDC11C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:07:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8F492173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:07:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rOdL+DUB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8F492173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E3656B0003; Tue, 16 Jul 2019 17:07:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3938C6B0005; Tue, 16 Jul 2019 17:07:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25B0F8E0001; Tue, 16 Jul 2019 17:07:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F14766B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:07:12 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o16so19251555qtj.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 14:07:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lU0ZKpvPEM02SqJNjy+uAeZT1GMqvehKcxtKUy4ZdV4=;
        b=HT1f2aV16MS5bchAvcimc1pspbPHpyK2AfE1SHKF69KuAbij8BD+ZG4bfl08aIGiMN
         mc+pi9JIndzcArOGvYVWZUEdtKIN1yJ6pkfJWqego8lt3vfygKk3FIOEBqBkAl9Gbeix
         1V2IuFZoD/AZnCFxE499ewoW749LNBA9zLN6c9wsANCMlXTjM9ZALfLaykVvGTgSnTaN
         rs7zxhPCgnn1E3cw+dqDvPjYiGtQnRKJes7aEwvLW+lseTng4v4rtJkBOU7ZqdyPPBvZ
         Rs3I3BQbW5PArN62QEs7jWXF34nRSuWiyptKnIA7GovOBzS3H1gDKhjQnvSXA7gJIgFQ
         ITZg==
X-Gm-Message-State: APjAAAX5/6VWE96G6a0hRowDHw7qGFiI5Yq0QCY8QFqWhUCSxzeEDRfS
	kQaXrQbJ8XajdwJKti19cqdM9WAQ2Y5KiK3GSvs4URcNOfvbybBukMDvZQfRwOSvDHMZdMZtPJ0
	HmiJH/lq6Hvdh5ydSwq8ynuI5kJDHR7hrBv/ZSmR1emqLC/grJ5Sku6cNCNkOxVDTBA==
X-Received: by 2002:a05:620a:124f:: with SMTP id a15mr23602878qkl.173.1563311232704;
        Tue, 16 Jul 2019 14:07:12 -0700 (PDT)
X-Received: by 2002:a05:620a:124f:: with SMTP id a15mr23602777qkl.173.1563311231135;
        Tue, 16 Jul 2019 14:07:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563311231; cv=none;
        d=google.com; s=arc-20160816;
        b=EUUlYm3LlgRfY+YiUL4agCxAFoTUKWqtPhdYVeinEpXc6U2AZGtOj0d/9ByRPloUQJ
         5nNhCHR8TakngUethyUxgafkdDTN4mw7tR5rVjUTJRKouP4X4YmjXHDh5gcTCO93oL0L
         mcRGj4gLMfEC3Fv95a9LQ4p/feTr17Dk4p68tk1Y5RjlMiFRDRrXtBYMJc7pKeMEVF6R
         fV+FX+36gExdBRqyn5qEvZumwf3q1/OTHTM7Iq2zxHF65sMjlPaUjv5fzWZKpX308JPQ
         HQnIWwsEcXv1JCFRY1KAcQBpkw5bVLRQNUJwH0PyYAaZ9RzdAs22aF7GEBgA9RzjeQ+t
         Tl8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lU0ZKpvPEM02SqJNjy+uAeZT1GMqvehKcxtKUy4ZdV4=;
        b=KZtaRzeGMrd7MgsQ7ZQGA9AVePmQZCY0oLpn5NmH4pyujBvc2yHcqpYossPUEtY9A7
         j+woT+kI4nh94G4vZPMbjIcUW4W37K9nd1GCF6QOSmJxnA+iS4nS2qpqMNE65zTF0QwH
         x0CYRvlHyVrV3UVjPdK2FsCs0GnpibeBc5+ZRg4PWrba0xpmvdJ+vrkyKRPfwp9l0teN
         Go5IIQPnEROzXvdDbAufag82oOLpO/fIG5PuG3WHI7exBKaNz3UOuZisHe22oWJ//ley
         v5XXiR2n7l88udK8AN4QbEp+mEpr+hoRymvX+pH4E5ynFMY3uP7PuQU2G73FYr6hCBdt
         st6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rOdL+DUB;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q52sor29702647qte.3.2019.07.16.14.07.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 14:07:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rOdL+DUB;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lU0ZKpvPEM02SqJNjy+uAeZT1GMqvehKcxtKUy4ZdV4=;
        b=rOdL+DUB3An79WA+jPt9CMyw8MQxV91n8PIHvK6IJiWgQtrywzryWK6lI+sXoku94C
         cQKvqy4QEHF2aN8DyZ2sBwxx2l7eXZrsQkKivPTgYSKYgg/+xWXZES0GVCy5epaVnlih
         qGIJ+/pYkZIIg/5VtmE80Ky9PAOMTQRECOWrCnLwNUtySSyfnjjHjHxFvfwdQS2JoBnh
         tQo3H3FkRsQywCOzy/OXl/q6t3ucoosNiPJtUh6pEQ5CHAp0Vy39ABpiZP4YhVJvsPk0
         ouUR4f1JyR5Hf3+19/k4ddY/EJ1FF+jF6axym7qj68Dsj8c2hpIVAUOyy2vKfq3EIMUa
         oXQg==
X-Google-Smtp-Source: APXvYqxSi83uaBDrLmOo3wSuY6zQNktY2GDbKYBvzNCkongdEuyCLYoe4d5ugxdDzo4TmrLBBlAf0mMjQ7pyUBrP0w0=
X-Received: by 2002:aed:3742:: with SMTP id i60mr24421385qtb.376.1563311230570;
 Tue, 16 Jul 2019 14:07:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain> <20190716055017-mutt-send-email-mst@kernel.org>
 <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
 <20190716115535-mutt-send-email-mst@kernel.org> <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190716125845-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 16 Jul 2019 14:06:59 -0700
Message-ID: <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 10:41 AM Michael S. Tsirkin <mst@redhat.com> wrote:

<snip>

> > > This is what I am saying. Having watched that patchset being developed,
> > > I think that's simply because processing blocks required mm core
> > > changes, which Wei was not up to pushing through.
> > >
> > >
> > > If we did
> > >
> > >         while (1) {
> > >                 alloc_pages
> > >                 add_buf
> > >                 get_buf
> > >                 free_pages
> > >         }
> > >
> > > We'd end up passing the same page to balloon again and again.
> > >
> > > So we end up reserving lots of memory with alloc_pages instead.
> > >
> > > What I am saying is that now that you are developing
> > > infrastructure to iterate over free pages,
> > > FREE_PAGE_HINT should be able to use it too.
> > > Whether that's possible might be a good indication of
> > > whether the new mm APIs make sense.
> >
> > The problem is the infrastructure as implemented isn't designed to do
> > that. I am pretty certain this interface will have issues with being
> > given small blocks to process at a time.
> >
> > Basically the design for the FREE_PAGE_HINT feature doesn't really
> > have the concept of doing things a bit at a time. It is either
> > filling, stopped, or done. From what I can tell it requires a
> > configuration change for the virtio balloon interface to toggle
> > between those states.
>
> Maybe I misunderstand what you are saying.
>
> Filling state can definitely report things
> a bit at a time. It does not assume that
> all of guest free memory can fit in a VQ.

I think where you and I may differ is that you are okay with just
pulling pages until you hit OOM, or allocation failures. Do I have
that right? In my mind I am wanting to perform the hinting on a small
block at a time and work through things iteratively.

The problem is the FREE_PAGE_HINT doesn't have the option of returning
pages until all pages have been pulled. It is run to completion and
will keep filling the balloon until an allocation fails and the host
says it is done. I would prefer to avoid that as I prefer to simply
notify the host of a fixed block of pages at a time and let it process
without having to have a thread on each side actively pushing pages,
or listening for the incoming pages.

> > > > The basic idea with the bubble hinting was to essentially create mini
> > > > balloons. As such I had based the code off of the balloon inflation
> > > > code. The only spot where it really differs is that I needed the
> > > > ability to pass higher order pages so I tweaked thinks and passed
> > > > "hints" instead of "pfns".
> > >
> > > And that is fine. But there isn't really such a big difference with
> > > FREE_PAGE_HINT except FREE_PAGE_HINT triggers upon host request and not
> > > in response to guest load.
> >
> > I disagree, I believe there is a significant difference.
>
> Yes there is, I just don't think it's in the iteration.
> The iteration seems to be useful to hinting.

I agree that iteration is useful to hinting. The problem is the
FREE_PAGE_HINT code isn't really designed to be iterative. It is
designed to run with a polling thread on each side and it is meant to
be run to completion.

> > The
> > FREE_PAGE_HINT code was implemented to be more of a streaming
> > interface.
>
> It's implemented like this but it does not follow from
> the interface. The implementation is a combination of
> attempts to minimize # of exits and minimize mm core changes.

The problem is the interface doesn't have a good way of indicating
that it is done with a block of pages.

So what I am probably looking at if I do a sg implementation for my
hinting is to provide one large sg block for all 32 of the pages I
might be holding. I'm assuming that will still be processed as one
contiguous block. With that I can then at least maintain a single
response per request.

> > This is one of the things Linus kept complaining about in
> > his comments. This code attempts to pull in ALL of the higher order
> > pages, not just a smaller block of them.
>
> It wants to report all higher order pages eventually, yes.
> But it's absolutely fine to report a chunk and then wait
> for host to process the chunk before reporting more.
>
> However, interfaces we came up with for this would call
> into virtio with a bunch of locks taken.
> The solution was to take pages off the free list completely.
> That in turn means we can't return them until
> we have processed all free memory.

I get that. The problem is the interface is designed around run to
completion. For example it will sit there in a busy loop waiting for a
free buffer because it knows the other side is suppose to be
processing the pages already.

> > Honestly the difference is
> > mostly in the hypervisor interface than what is needed for the kernel
> > interface, however the design of the hypervisor interface would make
> > doing things more incrementally much more difficult.
>
> OK that's interesting. The hypervisor interface is not
> documented in the spec yet. Let me take a stub at a writeup now. So:
>
>
>
> - hypervisor requests reporting by modifying command ID
>   field in config space, and interrupting guest
>
> - in response, guest sends the command ID value on a special
>   free page hinting VQ,
>   followed by any number of buffers. Each buffer is assumed
>   to be the address and length of memory that was
>   unused *at some point after the time when command ID was sent*.
>
>   Note that hypervisor takes pains to handle the case
>   where memory is actually no longer free by the time
>   it gets the memory.
>   This allows guest driver to take more liberties
>   and free pages without waiting for guest to
>   use the buffers.
>
>   This is also one of the reason we call this a free page hint -
>   the guarantee that page is free is a weak one,
>   in that sense it's more of a hint than a promise.
>   That helps guarantee we don't create OOM out of blue.
>
> - guest eventually sends a special buffer signalling to
>   host that it's done sending free pages.
>   It then stops reporting until command id changes.

The pages are not freed back to the guest until the host reports that
it is "DONE" via a configuration change. Doing that stops any further
progress, and attempting to resume will just restart from the
beginning.

The big piece this design is missing is the incremental notification
pages have been processed. The existing code just fills the vq with
pages and keeps doing it until it cannot allocate any more pages. We
would have to add logic to stop, flush, and resume to the existing
framework.

> - host can restart the process at any time by
>   updating command ID. That will make guest stop
>   and start from the beginning.
>
> - host can also stop the process by specifying a special
>   command ID value.
>
>
> =========
>
>
> Now let's compare to what you have here:
>
> - At any time after boot, guest walks over free memory and sends
>   addresses as buffers to the host
>
> - Memory reported is then guaranteed to be unused
>   until host has used the buffers
>
>
> Is above a fair summary?
>
> So yes there's a difference but the specific bit of chunking is same
> imho.

The big difference is that I am returning the pages after they are
processed, while FREE_PAGE_HINT doesn't and isn't designed to. The
problem is the interface doesn't allow for a good way to identify that
any given block of pages has been processed and can be returned.
Instead pages go in, but they don't come out until the configuration
is changed and "DONE" is reported. The act of reporting "DONE" will
reset things and start them all over which kind of defeats the point.

