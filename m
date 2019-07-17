Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3912BC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 10:29:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1289217F9
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 10:28:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1289217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09D9D6B0003; Wed, 17 Jul 2019 06:28:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04F3A6B0005; Wed, 17 Jul 2019 06:28:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7FC78E0001; Wed, 17 Jul 2019 06:28:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7F666B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 06:28:58 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id y19so20880065qtm.0
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:28:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=7ACYoq8M97yeAKzYOXxXtOnLMGk5BkUKP6VUntrtUQI=;
        b=gvQQ6413tiOdQS6WfY+GiegrtuVlNnSMSIHC0y1nyw9enVHFUa3nzyVQmqKIAOHUuN
         1SBkAhzpB0bbKjIi3saZcK6Ybw+YpKvyFV10Zo3F0/jdazCOftEy+CLIGYDL5lAPGRm6
         4Gv6stEgBef2AKTWXquSPF5jrpf6+CmXhu5s9mBnqEFXRDMeKtxV0DdTuucaPuqiaOTs
         7+DyhZe8ApA6U4AAuBCd6DANyEdag90tSQGmzXEFUoNNXnp/hOovrUEKKKuMqihgRIZq
         WZgotyszNO1Tm11hoZtARG03aOguhufyPEtWML1atjN1VBrW43zUbdk92vCznwF27LlX
         EKlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW5V9xBJ3mVIbXYWUg99c5exZOrxMgjPuSOilbIgXCQmxq+glzW
	dKqb1k/G0O24cR+4+Hj5jVf4JNKH0V871VJXmZeYv8sIQ81kIkQHyqD6IpSdkH55ur6xFtQ0GGF
	MV/ygpjKwBsqwLhRc7r4LwYcrMmZe5cozaMujOH8edx6rM0V6SHyHUestKgjNBjJTMw==
X-Received: by 2002:ac8:c45:: with SMTP id l5mr25887254qti.63.1563359338442;
        Wed, 17 Jul 2019 03:28:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0UKMCCjb7tdYysBdwQ2WP5l7f8DXXV99OHc1EHBb7IUIHRjbYnwuExTFEzDpbV3ibmlWw
X-Received: by 2002:ac8:c45:: with SMTP id l5mr25887196qti.63.1563359337278;
        Wed, 17 Jul 2019 03:28:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563359337; cv=none;
        d=google.com; s=arc-20160816;
        b=WsUvEw2Mv2jerpdtlh1MeBsrIO13bqduALHaDWHgOggJr32qcv0iTWqLC6Sv2pSMAw
         9gUI7FjPXtsrvqAOt+bZEMWSb30BmzUFOkwOuuLRY0QUeLVPnkO5MXBglCZcngY1lTMx
         xmc3kROCMDIZm3JZFButFuZPRGlohzbD+BwHhjzv+2CiNWBH9PY9zSWY7yvWJQsT9Iiu
         tAhUg7ZBI5xBN9r7/euUaK9LApUED2TbVhfwVHm8inGWfU/ef9YQFY5Rj3Ut42IyrxDR
         043uARH5mvTU4NuIVb3bof22K5gwehnxef96D5paRbCNTUoMr8A/tetylcKelZy11AZo
         AzZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=7ACYoq8M97yeAKzYOXxXtOnLMGk5BkUKP6VUntrtUQI=;
        b=saOOi0NCONRemaQo0OKMzF0fLkEFGyCBerlLyVneWHFbC3jbPH5UN7YgNgGwQ/UirI
         QTb61F+ciVPpa7/h1Ej+YA+bzMljkZtA51sopqVSKlFMdQjlcLFhoQorM62nLGf8LkDr
         kIvOraRf3M02kYknJFVTGnUEpsLlFksls9g73WZrsHDa1po0njlpaUZxTyaY1AaFDNkv
         Q06XPW7+l9RIzYoVPNLTh/Bozy/QVaQ5YzgAaxkLGjCZmnvx8gi+4NBpmKI/Drassaf/
         GxV66zXoh4ewR3YgDZBSJAJVUH+kKqZp1Ddqsbn67j3g/0Es/dWj5DDLUsxSCkCHyedD
         hR1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j6si11591019qkc.61.2019.07.17.03.28.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 03:28:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 11E6F335D6;
	Wed, 17 Jul 2019 10:28:56 +0000 (UTC)
Received: from redhat.com (ovpn-120-247.rdu2.redhat.com [10.10.120.247])
	by smtp.corp.redhat.com (Postfix) with SMTP id 1938919D7E;
	Wed, 17 Jul 2019 10:28:13 +0000 (UTC)
Date: Wed, 17 Jul 2019 06:28:12 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, wei.w.wang@intel.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190717055804-mutt-send-email-mst@kernel.org>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <CAKgT0Uc-2k9o7pjtf-GFAgr83c7RM-RTJ8-OrEzFv92uz+MTDw@mail.gmail.com>
 <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org>
 <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 17 Jul 2019 10:28:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 02:06:59PM -0700, Alexander Duyck wrote:
> On Tue, Jul 16, 2019 at 10:41 AM Michael S. Tsirkin <mst@redhat.com> wrote:
> 
> <snip>
> 
> > > > This is what I am saying. Having watched that patchset being developed,
> > > > I think that's simply because processing blocks required mm core
> > > > changes, which Wei was not up to pushing through.
> > > >
> > > >
> > > > If we did
> > > >
> > > >         while (1) {
> > > >                 alloc_pages
> > > >                 add_buf
> > > >                 get_buf
> > > >                 free_pages
> > > >         }
> > > >
> > > > We'd end up passing the same page to balloon again and again.
> > > >
> > > > So we end up reserving lots of memory with alloc_pages instead.
> > > >
> > > > What I am saying is that now that you are developing
> > > > infrastructure to iterate over free pages,
> > > > FREE_PAGE_HINT should be able to use it too.
> > > > Whether that's possible might be a good indication of
> > > > whether the new mm APIs make sense.
> > >
> > > The problem is the infrastructure as implemented isn't designed to do
> > > that. I am pretty certain this interface will have issues with being
> > > given small blocks to process at a time.
> > >
> > > Basically the design for the FREE_PAGE_HINT feature doesn't really
> > > have the concept of doing things a bit at a time. It is either
> > > filling, stopped, or done. From what I can tell it requires a
> > > configuration change for the virtio balloon interface to toggle
> > > between those states.
> >
> > Maybe I misunderstand what you are saying.
> >
> > Filling state can definitely report things
> > a bit at a time. It does not assume that
> > all of guest free memory can fit in a VQ.
> 
> I think where you and I may differ is that you are okay with just
> pulling pages until you hit OOM, or allocation failures. Do I have
> that right?

This is exactly what the current code does. But that's an implementation
detail which came about because we failed to find any other way to
iterate over free blocks.

> In my mind I am wanting to perform the hinting on a small
> block at a time and work through things iteratively.
> 
> The problem is the FREE_PAGE_HINT doesn't have the option of returning
> pages until all pages have been pulled. It is run to completion and
> will keep filling the balloon until an allocation fails and the host
> says it is done.

OK so there are two points. One is that FREE_PAGE_HINT does not
need to allocate a page at all. It really just wants to
iterate over free pages.


The reason FREE_PAGE_HINT does not free up pages until we finished
iterating over the free list it not a hypervisor API. The reason is we
don't want to keep getting the same address over and over again.

> I would prefer to avoid that as I prefer to simply
> notify the host of a fixed block of pages at a time and let it process
> without having to have a thread on each side actively pushing pages,
> or listening for the incoming pages.

Right. And FREE_PAGE_HINT can go even further. It can push a page and
let linux use it immediately. It does not even need to wait for host to
process anything unless the VQ gets full.

> 
> > > > > The basic idea with the bubble hinting was to essentially create mini
> > > > > balloons. As such I had based the code off of the balloon inflation
> > > > > code. The only spot where it really differs is that I needed the
> > > > > ability to pass higher order pages so I tweaked thinks and passed
> > > > > "hints" instead of "pfns".
> > > >
> > > > And that is fine. But there isn't really such a big difference with
> > > > FREE_PAGE_HINT except FREE_PAGE_HINT triggers upon host request and not
> > > > in response to guest load.
> > >
> > > I disagree, I believe there is a significant difference.
> >
> > Yes there is, I just don't think it's in the iteration.
> > The iteration seems to be useful to hinting.
> 
> I agree that iteration is useful to hinting. The problem is the
> FREE_PAGE_HINT code isn't really designed to be iterative. It is
> designed to run with a polling thread on each side and it is meant to
> be run to completion.

Absolutely. But that's a bug I think.

> > > The
> > > FREE_PAGE_HINT code was implemented to be more of a streaming
> > > interface.
> >
> > It's implemented like this but it does not follow from
> > the interface. The implementation is a combination of
> > attempts to minimize # of exits and minimize mm core changes.
> 
> The problem is the interface doesn't have a good way of indicating
> that it is done with a block of pages.
> 
> So what I am probably looking at if I do a sg implementation for my
> hinting is to provide one large sg block for all 32 of the pages I
> might be holding.

Right now if you pass an sg it will try to allocate a buffer
on demand for you. If this is a problem I could come up
with a new API that lets caller allocate the buffer.
Let me know.

> I'm assuming that will still be processed as one
> contiguous block. With that I can then at least maintain a single
> response per request.

Why do you care? Won't a counter of outstanding pages be enough?
Down the road maybe we could actually try to pipeline
things a bit. So send 32 pages once you get 16 of these back
send 16 more. Better for SMP configs and does not hurt
non-SMP too much. I am not saying we need to do it right away though.

> > > This is one of the things Linus kept complaining about in
> > > his comments. This code attempts to pull in ALL of the higher order
> > > pages, not just a smaller block of them.
> >
> > It wants to report all higher order pages eventually, yes.
> > But it's absolutely fine to report a chunk and then wait
> > for host to process the chunk before reporting more.
> >
> > However, interfaces we came up with for this would call
> > into virtio with a bunch of locks taken.
> > The solution was to take pages off the free list completely.
> > That in turn means we can't return them until
> > we have processed all free memory.
> 
> I get that. The problem is the interface is designed around run to
> completion. For example it will sit there in a busy loop waiting for a
> free buffer because it knows the other side is suppose to be
> processing the pages already.

I didn't get this part.

> > > Honestly the difference is
> > > mostly in the hypervisor interface than what is needed for the kernel
> > > interface, however the design of the hypervisor interface would make
> > > doing things more incrementally much more difficult.
> >
> > OK that's interesting. The hypervisor interface is not
> > documented in the spec yet. Let me take a stub at a writeup now. So:
> >
> >
> >
> > - hypervisor requests reporting by modifying command ID
> >   field in config space, and interrupting guest
> >
> > - in response, guest sends the command ID value on a special
> >   free page hinting VQ,
> >   followed by any number of buffers. Each buffer is assumed
> >   to be the address and length of memory that was
> >   unused *at some point after the time when command ID was sent*.
> >
> >   Note that hypervisor takes pains to handle the case
> >   where memory is actually no longer free by the time
> >   it gets the memory.
> >   This allows guest driver to take more liberties
> >   and free pages without waiting for guest to
> >   use the buffers.
> >
> >   This is also one of the reason we call this a free page hint -
> >   the guarantee that page is free is a weak one,
> >   in that sense it's more of a hint than a promise.
> >   That helps guarantee we don't create OOM out of blue.

I would like to stress the last paragraph above.


> >
> > - guest eventually sends a special buffer signalling to
> >   host that it's done sending free pages.
> >   It then stops reporting until command id changes.
> 
> The pages are not freed back to the guest until the host reports that
> it is "DONE" via a configuration change. Doing that stops any further
> progress, and attempting to resume will just restart from the
> beginning.

Right but it's not a requirement. Host does not assume this at all.
It's done like this simply because we can't iterate over pages
with the existing API.

> The big piece this design is missing is the incremental notification
> pages have been processed. The existing code just fills the vq with
> pages and keeps doing it until it cannot allocate any more pages. We
> would have to add logic to stop, flush, and resume to the existing
> framework.

But not to the hypervisor interface. Hypervisor is fine
with pages being reused immediately. In fact, even before they
are processed.

> > - host can restart the process at any time by
> >   updating command ID. That will make guest stop
> >   and start from the beginning.
> >
> > - host can also stop the process by specifying a special
> >   command ID value.
> >
> >
> > =========
> >
> >
> > Now let's compare to what you have here:
> >
> > - At any time after boot, guest walks over free memory and sends
> >   addresses as buffers to the host
> >
> > - Memory reported is then guaranteed to be unused
> >   until host has used the buffers
> >
> >
> > Is above a fair summary?
> >
> > So yes there's a difference but the specific bit of chunking is same
> > imho.
> 
> The big difference is that I am returning the pages after they are
> processed, while FREE_PAGE_HINT doesn't and isn't designed to.

It doesn't but the hypervisor *is* designed to support that.

> The
> problem is the interface doesn't allow for a good way to identify that
> any given block of pages has been processed and can be returned.

And that's because FREE_PAGE_HINT does not care.
It can return any page at any point even before hypervisor
saw it.

> Instead pages go in, but they don't come out until the configuration
> is changed and "DONE" is reported. The act of reporting "DONE" will
> reset things and start them all over which kind of defeats the point.

Right.

But if you consider how we are using the shrinker you will
see that it's kind of broken.
For example not keeping track of allocated
pages means the count we return is broken
while reporting is active.

I looked at fixing it but really if we can just
stop allocating memory that would be way cleaner.


For example we allocate pages until shrinker kicks in.
Fair enough but in fact many it would be better to
do the reverse: trigger shrinker and then send as many
free pages as we can to host.

-- 
MST

