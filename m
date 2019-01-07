Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3DCCC43612
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 06:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86C612087F
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 06:17:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NroKfAQ+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86C612087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34EBF8E0008; Mon,  7 Jan 2019 01:17:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D76A8E0001; Mon,  7 Jan 2019 01:17:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C6AD8E0008; Mon,  7 Jan 2019 01:17:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0EED8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 01:17:27 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id 18-v6so11055871ljn.8
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 22:17:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0vzhVfMyaVE2G7X9WbbGn0gD3CbF4zU9/bkHOHmr54c=;
        b=CeCrrgmIYLjEmN7z7aT6K+gRpo4ana5oewUAoMZ6WGI8fetyUszbT/VuK1DnhAjWSE
         z9XeOnKcpxgQYfUBOgCS7i2zRujjz1Jej6ZYnLIvloIorB3hoDO/kxRg3Ong9j8N8Jrz
         clbWfuQXnvaSl22e+fTtGKBgNrAgkd/Ou6kNsiSCAVDEu9GdiCKL4b3XeFJbTNS2ZipY
         vIOo+6bIuKoPXl4pEHp2+me3a0hi2srlXKHXGp0o/ecl/VTmQabAVeAhzpPnLZ2E32IP
         QU6UOfqvMwFPBfx2B2/aEACA6Zi+YGFCPL0y2MS//beyZ/b+nCuNauhVhj3RY5u2Mpk2
         v70A==
X-Gm-Message-State: AJcUukcjK/jQGTDzN8ycEK++oTttp4y0AtXv6V/cLHneUr2shFxaaHhL
	4F+a9cYBa/a9NOxrdhlNH9lgq3q/Fh05f60eLQCg7tjVLjYzJSBx7VM4VmH8Z6RB3XQJT1k+h7y
	6FW1oLQe0P0rvSqfFbvt7qgybAqDytPLzhsxMzU0kRGGOy6BG2aVUWekxvQzncbenGY21EyvBZi
	CulR76VHDTvpAip+xtGwhl0LPy+Gw4J2WQK0MgxAWXVYnz2X3ulNBhd4oY6DSSPm1o8R004ASHH
	eGUT//4470co31Q40z8+nTO6b6xtYvNQbq1UgdMg8Dy6ua78XadMeXfr3VMbC2KxQBXhF4ZF2My
	jOaa42HSllqjI30SEdV8SweA9PRKfrD+4AbUAwkSFyNtg9YQ/1OCrSfTxa0TsPGX3JbZ7TVaITl
	y
X-Received: by 2002:a2e:9b84:: with SMTP id z4-v6mr33133624lji.93.1546841846619;
        Sun, 06 Jan 2019 22:17:26 -0800 (PST)
X-Received: by 2002:a2e:9b84:: with SMTP id z4-v6mr33133582lji.93.1546841845375;
        Sun, 06 Jan 2019 22:17:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546841845; cv=none;
        d=google.com; s=arc-20160816;
        b=0VeRscOr17KNb9mj+ZEWFbKcLdek9syDt3S+2Tz+trQQc/yVXTFQTXZ4HtHefRz3vh
         j17I35gyo997g6eEjZ7cf0Wdzo4rMOuwGczomRTeQ2EHtwqf/2zARSjZ/uEB/q34Q0T+
         ntf+2I6vODzv7XacmfR3Gdk4+u5XwMdm2sPklnJSUoVgRcReD+wNz0Vz3JcbOPzxDgIP
         ckt3+alEoL5+kR/I7M3FFdWyrMcJKca/vHJ0ieaU6vvQEg9TqMknLRayaQ3Eiv8rztrp
         L+lMpSiOh6ZDaQEzDY6R7mBt/0B23GSEDLY6hKgYtWPWQjU7M2gxwoPY7YFX0Tzv0NN7
         DoZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0vzhVfMyaVE2G7X9WbbGn0gD3CbF4zU9/bkHOHmr54c=;
        b=oF00E4xR6V+G0uPUFAv/eF651oJkEqpeeQwEt1dbso0nwVqIOMbE3Gn266E7pBy7Jt
         g4jHHBCrUJjTvX+9ZbrQBIN8dDofSrHWpqrcKrqeijIG7+1LjwRNq9UYcPRATFOQgu2f
         6+h4oXomyetz/HhbPByVu0zdEzH+ruSw/EdEqVUV6HMN88iTXkR15lR57CAq2Bhdg3xZ
         OJLkwNlszcyDsw30iDuR2+YmDnChXVa9hcwJtk+YVhsLB3Y2VX7e0UvrtROX5P3oAo2h
         efR72qnUphJ3fGjfW7CCjp/GVQormZJvElBNhv9i4IQnel0fGRfRfLdx6HpUotdBVM6C
         esAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NroKfAQ+;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x22-v6sor35707007ljh.16.2019.01.06.22.17.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 06 Jan 2019 22:17:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NroKfAQ+;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0vzhVfMyaVE2G7X9WbbGn0gD3CbF4zU9/bkHOHmr54c=;
        b=NroKfAQ+6X0bqmf78NspHZegaUkFDwj1v8kkevhQyOMI3CpAeqHEUeFrnVdrJAA5LQ
         qnGhmcjuIIws6t6IUKBWdVm/MnqNSEs1HJ5oBI2ci91fX93qsmYsN/ZQpXhAlcT2eKdP
         CLfOclT416eLauCYx8m/JB9XeBTmSOrv9/vZXvFL5XTjOKL3h9/GVaaErSxZQontiQoK
         cCGzgu5yGHrRDqYnhimNJxeNzBqLVmN7hyqSRqGLwoD/j+gyd8BmBCR6VTsr+Pn7QA0J
         T5ghYOc8OjATBjg2EzYauQCR44QgITSmJ0Gu5FU+YACENuJNV7F1cNfOQ4fjApuGQ1Ds
         dPdA==
X-Google-Smtp-Source: ALg8bN658FWprzgnhzUSU3BPWxfaBTH9jUd/qzD6aJCAiA9qDYETepC1wORlBUcRg0WbmmhXFrMJPimNbFFiyevyLyk=
X-Received: by 2002:a2e:9c52:: with SMTP id t18-v6mr27550357ljj.149.1546841844697;
 Sun, 06 Jan 2019 22:17:24 -0800 (PST)
MIME-Version: 1.0
References: <20181106120544.GA3783@jordon-HP-15-Notebook-PC>
 <20181115014737.GA2353@rapoport-lnx> <CAFqt6zbOgSm9omt+6iV0GJtZdZ_qyTr9Jte9ZGYRQ1M4CdB-mA@mail.gmail.com>
 <CAFqt6zZ67tFA8FjFZ4xM+YUAez9EdPHinx0ky0X5sQHyZ9nkLg@mail.gmail.com>
In-Reply-To: <CAFqt6zZ67tFA8FjFZ4xM+YUAez9EdPHinx0ky0X5sQHyZ9nkLg@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 7 Jan 2019 11:47:12 +0530
Message-ID:
 <CAFqt6zYY=xfqvVxRi1spbMNzvoM_CYNxbm6d7_79a5bBHxUzuA@mail.gmail.com>
Subject: Re: [PATCH v3] mm: Create the new vm_fault_t type
To: rppt@linux.ibm.com, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, 
	Matthew Wilcox <willy@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, riel@redhat.com, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107061712.YcHt0DxgYNz1kBx6wD12sf_LIa_LUDR2YuIMjBNPFBk@z>

On Fri, Dec 14, 2018 at 10:35 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Hi Andrew,
>
> On Sat, Nov 24, 2018 at 10:16 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
> >
> > On Thu, Nov 15, 2018 at 7:17 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > >
> > > On Tue, Nov 06, 2018 at 05:36:42PM +0530, Souptick Joarder wrote:
> > > > Page fault handlers are supposed to return VM_FAULT codes,
> > > > but some drivers/file systems mistakenly return error
> > > > numbers. Now that all drivers/file systems have been converted
> > > > to use the vm_fault_t return type, change the type definition
> > > > to no longer be compatible with 'int'. By making it an unsigned
> > > > int, the function prototype becomes incompatible with a function
> > > > which returns int. Sparse will detect any attempts to return a
> > > > value which is not a VM_FAULT code.
> > > >
> > > > VM_FAULT_SET_HINDEX and VM_FAULT_GET_HINDEX values are changed
> > > > to avoid conflict with other VM_FAULT codes.
> > > >
> > > > Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> > >
> > > For the docs part
> > > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > >
> > > > ---
> > > > v2: Updated the change log and corrected the document part.
> > > >     name added to the enum that kernel-doc able to parse it.
> > > >
> > > > v3: Corrected the documentation.
> >
> > If no further comment, can we get this patch in queue for 4.21 ?
>
> Do I need to make any further improvement for this patch ?

If no further comment, can we get this patch in queue for 5.0-rcX ?

> >
> > > >
> > > >  include/linux/mm.h       | 46 ------------------------------
> > > >  include/linux/mm_types.h | 73 +++++++++++++++++++++++++++++++++++++++++++++++-
> > > >  2 files changed, 72 insertions(+), 47 deletions(-)
> > > >
> > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > index fcf9cc9..511a3ce 100644
> > > > --- a/include/linux/mm.h
> > > > +++ b/include/linux/mm.h
> > > > @@ -1267,52 +1267,6 @@ static inline void clear_page_pfmemalloc(struct page *page)
> > > >  }
> > > >
> > > >  /*
> > > > - * Different kinds of faults, as returned by handle_mm_fault().
> > > > - * Used to decide whether a process gets delivered SIGBUS or
> > > > - * just gets major/minor fault counters bumped up.
> > > > - */
> > > > -
> > > > -#define VM_FAULT_OOM 0x0001
> > > > -#define VM_FAULT_SIGBUS      0x0002
> > > > -#define VM_FAULT_MAJOR       0x0004
> > > > -#define VM_FAULT_WRITE       0x0008  /* Special case for get_user_pages */
> > > > -#define VM_FAULT_HWPOISON 0x0010     /* Hit poisoned small page */
> > > > -#define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
> > > > -#define VM_FAULT_SIGSEGV 0x0040
> > > > -
> > > > -#define VM_FAULT_NOPAGE      0x0100  /* ->fault installed the pte, not return page */
> > > > -#define VM_FAULT_LOCKED      0x0200  /* ->fault locked the returned page */
> > > > -#define VM_FAULT_RETRY       0x0400  /* ->fault blocked, must retry */
> > > > -#define VM_FAULT_FALLBACK 0x0800     /* huge page fault failed, fall back to small */
> > > > -#define VM_FAULT_DONE_COW   0x1000   /* ->fault has fully handled COW */
> > > > -#define VM_FAULT_NEEDDSYNC  0x2000   /* ->fault did not modify page tables
> > > > -                                      * and needs fsync() to complete (for
> > > > -                                      * synchronous page faults in DAX) */
> > > > -
> > > > -#define VM_FAULT_ERROR       (VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
> > > > -                      VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
> > > > -                      VM_FAULT_FALLBACK)
> > > > -
> > > > -#define VM_FAULT_RESULT_TRACE \
> > > > -     { VM_FAULT_OOM,                 "OOM" }, \
> > > > -     { VM_FAULT_SIGBUS,              "SIGBUS" }, \
> > > > -     { VM_FAULT_MAJOR,               "MAJOR" }, \
> > > > -     { VM_FAULT_WRITE,               "WRITE" }, \
> > > > -     { VM_FAULT_HWPOISON,            "HWPOISON" }, \
> > > > -     { VM_FAULT_HWPOISON_LARGE,      "HWPOISON_LARGE" }, \
> > > > -     { VM_FAULT_SIGSEGV,             "SIGSEGV" }, \
> > > > -     { VM_FAULT_NOPAGE,              "NOPAGE" }, \
> > > > -     { VM_FAULT_LOCKED,              "LOCKED" }, \
> > > > -     { VM_FAULT_RETRY,               "RETRY" }, \
> > > > -     { VM_FAULT_FALLBACK,            "FALLBACK" }, \
> > > > -     { VM_FAULT_DONE_COW,            "DONE_COW" }, \
> > > > -     { VM_FAULT_NEEDDSYNC,           "NEEDDSYNC" }
> > > > -
> > > > -/* Encode hstate index for a hwpoisoned large page */
> > > > -#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
> > > > -#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
> > > > -
> > > > -/*
> > > >   * Can be called by the pagefault handler when it gets a VM_FAULT_OOM.
> > > >   */
> > > >  extern void pagefault_out_of_memory(void);
> > > > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > > > index 5ed8f62..cb25016 100644
> > > > --- a/include/linux/mm_types.h
> > > > +++ b/include/linux/mm_types.h
> > > > @@ -22,7 +22,6 @@
> > > >  #endif
> > > >  #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
> > > >
> > > > -typedef int vm_fault_t;
> > > >
> > > >  struct address_space;
> > > >  struct mem_cgroup;
> > > > @@ -609,6 +608,78 @@ static inline bool mm_tlb_flush_nested(struct mm_struct *mm)
> > > >
> > > >  struct vm_fault;
> > > >
> > > > +/**
> > > > + * typedef vm_fault_t - Return type for page fault handlers.
> > > > + *
> > > > + * Page fault handlers return a bitmask of %VM_FAULT values.
> > > > + */
> > > > +typedef __bitwise unsigned int vm_fault_t;
> > > > +
> > > > +/**
> > > > + * enum vm_fault_reason - Page fault handlers return a bitmask of
> > > > + * these values to tell the core VM what happened when handling the
> > > > + * fault. Used to decide whether a process gets delivered SIGBUS or
> > > > + * just gets major/minor fault counters bumped up.
> > > > + *
> > > > + * @VM_FAULT_OOM:            Out Of Memory
> > > > + * @VM_FAULT_SIGBUS:         Bad access
> > > > + * @VM_FAULT_MAJOR:          Page read from storage
> > > > + * @VM_FAULT_WRITE:          Special case for get_user_pages
> > > > + * @VM_FAULT_HWPOISON:               Hit poisoned small page
> > > > + * @VM_FAULT_HWPOISON_LARGE: Hit poisoned large page. Index encoded
> > > > + *                           in upper bits
> > > > + * @VM_FAULT_SIGSEGV:                segmentation fault
> > > > + * @VM_FAULT_NOPAGE:         ->fault installed the pte, not return page
> > > > + * @VM_FAULT_LOCKED:         ->fault locked the returned page
> > > > + * @VM_FAULT_RETRY:          ->fault blocked, must retry
> > > > + * @VM_FAULT_FALLBACK:               huge page fault failed, fall back to small
> > > > + * @VM_FAULT_DONE_COW:               ->fault has fully handled COW
> > > > + * @VM_FAULT_NEEDDSYNC:              ->fault did not modify page tables and needs
> > > > + *                           fsync() to complete (for synchronous page faults
> > > > + *                           in DAX)
> > > > + * @VM_FAULT_HINDEX_MASK:    mask HINDEX value
> > > > + *
> > > > + */
> > > > +enum vm_fault_reason {
> > > > +     VM_FAULT_OOM            = (__force vm_fault_t)0x000001,
> > > > +     VM_FAULT_SIGBUS         = (__force vm_fault_t)0x000002,
> > > > +     VM_FAULT_MAJOR          = (__force vm_fault_t)0x000004,
> > > > +     VM_FAULT_WRITE          = (__force vm_fault_t)0x000008,
> > > > +     VM_FAULT_HWPOISON       = (__force vm_fault_t)0x000010,
> > > > +     VM_FAULT_HWPOISON_LARGE = (__force vm_fault_t)0x000020,
> > > > +     VM_FAULT_SIGSEGV        = (__force vm_fault_t)0x000040,
> > > > +     VM_FAULT_NOPAGE         = (__force vm_fault_t)0x000100,
> > > > +     VM_FAULT_LOCKED         = (__force vm_fault_t)0x000200,
> > > > +     VM_FAULT_RETRY          = (__force vm_fault_t)0x000400,
> > > > +     VM_FAULT_FALLBACK       = (__force vm_fault_t)0x000800,
> > > > +     VM_FAULT_DONE_COW       = (__force vm_fault_t)0x001000,
> > > > +     VM_FAULT_NEEDDSYNC      = (__force vm_fault_t)0x002000,
> > > > +     VM_FAULT_HINDEX_MASK    = (__force vm_fault_t)0x0f0000,
> > > > +};
> > > > +
> > > > +/* Encode hstate index for a hwpoisoned large page */
> > > > +#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 16))
> > > > +#define VM_FAULT_GET_HINDEX(x) (((x) >> 16) & 0xf)
> > > > +
> > > > +#define VM_FAULT_ERROR (VM_FAULT_OOM | VM_FAULT_SIGBUS |     \
> > > > +                     VM_FAULT_SIGSEGV | VM_FAULT_HWPOISON |  \
> > > > +                     VM_FAULT_HWPOISON_LARGE | VM_FAULT_FALLBACK)
> > > > +
> > > > +#define VM_FAULT_RESULT_TRACE \
> > > > +     { VM_FAULT_OOM,                 "OOM" },        \
> > > > +     { VM_FAULT_SIGBUS,              "SIGBUS" },     \
> > > > +     { VM_FAULT_MAJOR,               "MAJOR" },      \
> > > > +     { VM_FAULT_WRITE,               "WRITE" },      \
> > > > +     { VM_FAULT_HWPOISON,            "HWPOISON" },   \
> > > > +     { VM_FAULT_HWPOISON_LARGE,      "HWPOISON_LARGE" },     \
> > > > +     { VM_FAULT_SIGSEGV,             "SIGSEGV" },    \
> > > > +     { VM_FAULT_NOPAGE,              "NOPAGE" },     \
> > > > +     { VM_FAULT_LOCKED,              "LOCKED" },     \
> > > > +     { VM_FAULT_RETRY,               "RETRY" },      \
> > > > +     { VM_FAULT_FALLBACK,            "FALLBACK" },   \
> > > > +     { VM_FAULT_DONE_COW,            "DONE_COW" },   \
> > > > +     { VM_FAULT_NEEDDSYNC,           "NEEDDSYNC" }
> > > > +
> > > >  struct vm_special_mapping {
> > > >       const char *name;       /* The name, e.g. "[vdso]". */
> > > >
> > > > --
> > > > 1.9.1
> > > >
> > >
> > > --
> > > Sincerely yours,
> > > Mike.
> > >

