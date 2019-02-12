Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9DCBC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:02:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A0DB2084E
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:02:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A0DB2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7B308E0002; Tue, 12 Feb 2019 13:02:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2C408E0001; Tue, 12 Feb 2019 13:02:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF4808E0002; Tue, 12 Feb 2019 13:02:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75D688E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:02:34 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id s50so2742982edd.11
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:02:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IvGYcGEhIJfKL6pd/bizbp8blrfwyHyp4XuEIJTuGTo=;
        b=sEau4Qp5GepxryEhoMwkcgd2Rj+lgtoANo0pRixjORm92aeW//tWGT9zT0V5Bnt6xb
         mSa8shLWICtcX/4bivIP5c/49alQhxks5LV9uz+PXqSiVWy7K2RB/Lsr1hR74ZtMehmh
         /zScDHnxzdJdIkf9rdnvcQ+dd42YEgppDqFbaxOO3/89ShIkM1WuYkTepjzwXIqw1e66
         drV9e6BvgGkgSAJQ665veWBQxcG00+hJo4hZhZmpjBB2c+E5V++eF6sauEVuC7v74vmy
         +gRX0SxVQzqimUY/9B6jdoI7a0FuhxG8PjY1mysPJPL9wOwj7ijBBiTVqAjVFFoGWydg
         ypiA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuZfcdmT4efYGo+FV2r4IcuHb8D3Ls+vhWytAiS3pp6uPFmKoKeW
	zSm37j9pUCm94xMO/izr1z9+xj8UM7JroYRuUE5yW2azBAu0Z9emJpyVHC+IQBxPHt1PdpeGPM3
	H/nNV5e14J1Dd5SJq55dYHmTKRN3r1e8n8iaBhDtOvCMcF8d0QrYFcQSD7/XvlAeKjw==
X-Received: by 2002:a17:906:24da:: with SMTP id f26mr3699921ejb.136.1549994553899;
        Tue, 12 Feb 2019 10:02:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYoeEZtVe8u36eXvCWVDpqeyOtJPdGJgqMUZYs+917mAHa7NQG6a4+PRMBJ3f8O3Ddk45UO
X-Received: by 2002:a17:906:24da:: with SMTP id f26mr3699851ejb.136.1549994552703;
        Tue, 12 Feb 2019 10:02:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549994552; cv=none;
        d=google.com; s=arc-20160816;
        b=LOVVAdqQ6aUT2kYGT5vL1V9FbNlIut3sMNJzopPmBGg9RNY7oKpvQbTLz5GIHR1sXr
         dlhrea2oViKxuPURU/TY15aFhP0z/ccq32bDaKJF7rl4CSW8z0ektMTymG3ncBvjHzIq
         Cqzszi0tKy/FKT3OlysMoIv7mEF+X9eLnir8DLraCkA1KTaYguzkYXv+sEdJofrxbxKy
         0iqoii5B7mL77pBo1YPBtOWb0WN+kTqt0pSL5SfSIbQposQ9nsXRXWCrNDiFp5k8ezBA
         NRd2nU3UWk/oE74XoMe8G9XQbjuZkM/nKRHK32kunhTYdTJm2nYJsUOzlsClgXD/LWhQ
         T5oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IvGYcGEhIJfKL6pd/bizbp8blrfwyHyp4XuEIJTuGTo=;
        b=dC8ep8cTQq/sRltW266+gDMb3aoWUFqtGE/xv/T6Ip831feK9mFRYWcLkBjIoganxg
         3SCJ017apYmGJ4tnUKBYRpHykic1ht2zyIHgj2OMmCJ8Lc+G9VET1TydX0AYX9dYKA1c
         IS5OBwQYoQZkyUwNW00f8bk4X9CnTMY9szrYnNfNL9Nf+mxKJLAYRQH0gA6JTHtj49VJ
         1opTu89+syjTwt93oJxwit7kocqHkuGC0bUXb82qc8LG14NUqVQowIYzL/+umRJ7BuA+
         wmqCSMIeRN5QjI8kRQc29yulEx2XOyTxDvDeDTQD7aV5ShoxcuUNtWRUhFnnInJYu+Ho
         Q3VA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w27si609647edl.193.2019.02.12.10.02.32
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 10:02:32 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 70F181596;
	Tue, 12 Feb 2019 10:02:31 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BDEF33F675;
	Tue, 12 Feb 2019 10:02:26 -0800 (PST)
Date: Tue, 12 Feb 2019 18:02:24 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Evgenii Stepanov <eugenis@google.com>
Cc: Kevin Brodsky <kevin.brodsky@arm.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Will Deacon <will.deacon@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [RFC][PATCH 0/3] arm64 relaxed ABI
Message-ID: <20190212180223.GD199333@arrakis.emea.arm.com>
References: <cover.1544445454.git.andreyknvl@google.com>
 <20181210143044.12714-1-vincenzo.frascino@arm.com>
 <CAAeHK+xPZ-Z9YUAq=3+hbjj4uyJk32qVaxZkhcSAHYC4mHAkvQ@mail.gmail.com>
 <20181212150230.GH65138@arrakis.emea.arm.com>
 <CAAeHK+zxYJDJ7DJuDAOuOMgGvckFwMAoVUTDJzb6MX3WsXhRTQ@mail.gmail.com>
 <20181218175938.GD20197@arrakis.emea.arm.com>
 <20181219125249.GB22067@e103592.cambridge.arm.com>
 <9bbacb1b-6237-f0bb-9bec-b4cf8d42bfc5@arm.com>
 <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFKCwrhH5R3e5ntX0t-gxcE6zzbCNm06pzeFfYEN2K13c5WLTg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:32:55PM -0800, Evgenii Stepanov wrote:
> On Mon, Feb 11, 2019 at 9:28 AM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
> > On 19/12/2018 12:52, Dave Martin wrote:
> > > Really, the kernel should do the expected thing with all "non-weird"
> > > memory.
> > >
> > > In lieu of a proper definition of "non-weird", I think we should have
> > > some lists of things that are explicitly included, and also excluded:
> > >
> > > OK:
> > >       kernel-allocated process stack
> > >       brk area
> > >       MAP_ANONYMOUS | MAP_PRIVATE
> > >       MAP_PRIVATE mappings of /dev/zero
> > >
> > > Not OK:
> > >       MAP_SHARED
> > >       mmaps of non-memory-like devices
> > >       mmaps of anything that is not a regular file
> > >       the VDSO
> > >       ...
> > >
> > > In general, userspace can tag memory that it "owns", and we do not assume
> > > a transfer of ownership except in the "OK" list above.  Otherwise, it's
> > > the kernel's memory, or the owner is simply not well defined.
> >
> > Agreed on the general idea: a process should be able to pass tagged pointers at the
> > syscall interface, as long as they point to memory privately owned by the process. I
> > think it would be possible to simplify the definition of "non-weird" memory by using
> > only this "OK" list:
> > - mmap() done by the process itself, where either:
> >    * flags = MAP_PRIVATE | MAP_ANONYMOUS
> >    * flags = MAP_PRIVATE and fd refers to a regular file or a well-defined list of
> > device files (like /dev/zero)
> > - brk() done by the process itself
> > - Any memory mapped by the kernel in the new process's address space during execve(),
> > with the same restrictions as above ([vdso]/[vvar] are therefore excluded)

Sounds reasonable.

> > >   * Userspace should set tags at the point of allocation only.
> >
> > Yes, tags are only supposed to be set at the point of either allocation or
> > deallocation/reallocation. However, allocators can in principle be nested, so an
> > allocator could  take a region allocated by malloc() as input and subdivide it
> > (changing tags in the process). That said, this suballocator must not free() that
> > region until all the suballocations themselves have been freed (thereby restoring the
> > tags initially set by malloc()).
> >
> > >   * If you don't know how an object was allocated, you cannot modify the
> > >     tag, period.
> >
> > Agreed, allocators that tag memory can only operate on memory with a well-defined
> > provenance (for instance anonymous mmap() or malloc()).
> >
> > >   * A single C object should be accessed using a single, fixed pointer tag
> > >     throughout its entire lifetime.
> >
> > Agreed. Allocators themselves may need to be excluded though, depending on how they
> > represent their managed memory.
> >
> > >   * Tags can be changed only when there are no outstanding pointers to
> > >     the affected object or region that may be used to access the object
> > >     or region (i.e., if the object were allocated from the C heap and
> > >     is it safe to realloc() it, then it is safe to change the tag; for
> > >     other types of allocation, analogous arguments can be applied).
> >
> > Tags can only be changed at the point of deallocation/reallocation. Pointers to the
> > object become invalid and cannot be used after it has been deallocated; memory
> > tagging allows to catch such invalid usage.

All the above sound well but that's mostly a guideline on what a C
library can do. It doesn't help much with defining the kernel ABI.
Anyway, it's good to clarify the use-cases.

> > >   * When the kernel dereferences a pointer on userspace's behalf, it
> > >     shall behave equivalently to userspace dereferencing the same pointer,
> > >     including use of the same tag (where passed by userspace).
> > >
> > >   * Where the pointer tag affects pointer dereference behaviour (i.e.,
> > >     with hardware memory colouring) the kernel makes no guarantee to
> > >     honour pointer tags correctly for every location a buffer based on a
> > >     pointer passed by userspace to the kernel.
> > >
> > >     (This means for example that for a read(fd, buf, size), we can check
> > >     the tag for a single arbitrary location in *(char (*)[size])buf
> > >     before passing the buffer to get_user_pages().  Hopefully this could
> > >     be done in get_user_pages() itself rather than hunting call sites.
> > >     For userspace, it means that you're on your own if you ask the
> > >     kernel to operate on a buffer than spans multiple, independently-
> > >     allocated objects, or a deliberately striped single object.)
> >
> > I think both points are reasonable. It is very valuable for the kernel to access
> > userspace memory using the user-provided tag, because it enables kernel accesses to
> > be checked in the same way as user accesses, allowing to detect bugs that are
> > potentially hard to find. For instance, if a pointer to an object is passed to the
> > kernel after it has been deallocated, this is invalid and should be detected.
> > However, you are absolutely right that the kernel cannot *guarantee* that such a
> > check is carried out for the entire memory range (or in fact at all); it should be a
> > best-effort approach.
> 
> It would also be valuable to narrow down the set of "relaxed" (i.e.
> not tag-checking) syscalls as reasonably possible. We would want to
> provide tag-checking userspace wrappers for any important calls that
> are not checked in the kernel. Is it correct to assume that anything
> that goes through copy_from_user  / copy_to_user is checked?

I lost track of the context of this thread but if it's just about
relaxing the ABI for hwasan, the kernel has no idea of the compiler
generated structures in user space, so nothing is checked.

If we talk about tags in the context of MTE, than yes, with the current
proposal the tag would be checked by copy_*_user() functions.

> > >   * The kernel shall not extend the lifetime of user pointers in ways
> > >     that are not clear from the specification of the syscall or
> > >     interface to which the pointer is passed (and in any case shall not
> > >     extend pointer lifetimes without good reason).
> > >
> > >     So no clever transparent caching between syscalls, unless it _really_
> > >     is transparent in the presence of tags.
> >
> > Do you have any particular case in mind? If such caching is really valuable, it is
> > always possible to access the object while ignoring the tag. For sure, the
> > user-provided tag can only be used during the syscall handling itself, not
> > asynchronously later on, unless otherwise specified.
> 
> For aio* operations it would be nice if the tag was checked at the
> time of the actual userspace read/write, either instead of or in
> addition to at the time of the system call.

With aio* (and synchronous iovec-based syscalls), the kernel may access
the memory while the corresponding user process is scheduled out. Given
that such access is not done in the context of the user process (and
using the user VA like copy_*_user), the kernel cannot handle potential
tag faults. Moreover, the transfer may be done by DMA and the device
does not understand tags.

I'd like to keep tags as a property of the pointer in a specific virtual
address space. The moment you convert it to a different address space
(e.g. kernel linear map, physical address), the tag property is stripped
and I don't think we should re-build it (and have it checked).

> > >   * For purposes other than dereference, the kernel shall accept any
> > >     legitimately tagged pointer (according to the above rules) as
> > >     identifying the associated memory location.
> > >
> > >     So, mprotect(some_page_aligned_object, ...); is valid irrespective
> > >     of where page_aligned_object() came from.  There is no implicit
> > >     derefence by the kernel here, hence no tag check.
> > >
> > >     The kernel does not guarantee to work correctly if the wrong tag
> > >     is used, but there is not always a well-defined "right" tag, so
> > >     we can't really guarantee to check it.  So a pointer derived by
> > >     any reasonable means by userspace has to be treated as equally
> > >     valid.
> >
> > This is a disputed point :) In my opinion, this is the the most reasonable approach.
> 
> Yes, it would be nice if the kernel explicitly promised, ex.
> mprotect() over a range of differently tagged pages to be allowed
> (i.e. address tag should be unchecked).

I don't think mprotect() over differently tagged pages was ever a
problem. I originally asked that mprotect() and friends do not accept
tagged pointers since these functions deal with memory ranges rather
than dereferencing such pointer (the reason being minimal kernel
changes). However, given how complicated it is to specify an ABI, I came
to the conclusion that a pointer passed to such function should be
allowed to have non-zero top byte. It would be the kernel's
responsibility to strip it out as appropriate.

-- 
Catalin

