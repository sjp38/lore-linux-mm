Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA236C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 601C320675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:08:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="cSYLQtG/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 601C320675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF5BA8E0003; Thu,  7 Mar 2019 22:08:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA5288E0002; Thu,  7 Mar 2019 22:08:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6C728E0003; Thu,  7 Mar 2019 22:08:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0508E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:08:42 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w134so14892934qka.6
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:08:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=iSC5NRaIYEqe1epLXpU+YNht7NR85W950XiWInzYTE4=;
        b=AdEg0XjVeYwTcUr1oDHdd+OvdHv5jFV7pineEiKSdHchTuRin+hHrsWhMkNbsjd3Lz
         cjdw+RPqFdWQNttx8s9Ta7a83IuQmlxJF1j7BH5fTwGKNTcsMTDOgrlGp0nrYN2sBlIg
         PA+SrAVOorLEgTzqg73AljMmGsKy/DGlIsl5zDf+7webj8dKE/Ipspb+RAY06GURIckp
         q9dF+YiN6AqtVGEKIco9rT91AAj1GbU2AROLrW4N5y5Z7fipNaezMne8WE4k3eEHIeNm
         F4ffII6sIMB3jIa4ox6Dan/gxue4iPtYK2gGThfQuYrlNwaeOQ2pd0CWLRuTUeaMPR0w
         p/2w==
X-Gm-Message-State: APjAAAX0++d2zKapCJr1V1TtMB07T4DudGRQjdsaOeIWsQIVJu8D1EGv
	AexNL4Ma7tUfI0qNWmyx0s4b3X2jVH4RYdrQ+/OBL6QGuuNNur4pzGCf5Y6edXpDFqCvKq94fM0
	D/C5WoAM5cJ56BGTeFeKL3ug8FhE7f/riXKfSxyvUCKr/Oub61ZDPBR0GbL3VzTQ=
X-Received: by 2002:a0c:ba9d:: with SMTP id x29mr13404901qvf.112.1552014522356;
        Thu, 07 Mar 2019 19:08:42 -0800 (PST)
X-Google-Smtp-Source: APXvYqwdwDZROvSJNOk1GfLImg448we2xgy5nAek0biXZ85jK9I/QIpObeAGfGPhpjG7CbYVBbyr
X-Received: by 2002:a0c:ba9d:: with SMTP id x29mr13404866qvf.112.1552014521482;
        Thu, 07 Mar 2019 19:08:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552014521; cv=none;
        d=google.com; s=arc-20160816;
        b=Zd18/oma3sNcLFupgqF0SnD4DRjZnrLeanuK8pa+Fv+OH/pEaHXl9qT1b9eYtxf3YY
         odQ3jyklCMC5ZKpE4aZWobi16SI0If2htehITugFKz3VlJeTfHPNWyXWCbwao/MH8xR5
         W5L4LK4Bt3APHOjoPqp4eZ+oMoMKwAWnBUvOWBt4o1l7HPF+Y5IaeU9qottCdAkScQhN
         chlGqalVDW0omRQB36EetWp4wzNExmrmGkYKDHxWOO00E9SkTlJn9qzh2j4P6dF89wZz
         3y/ZUHnkDHK/waDE5lYzz68hs0FudlwgktBJi5vhR3QlOBZamcwkOO6oIPdPgbHtzkIo
         +NDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=iSC5NRaIYEqe1epLXpU+YNht7NR85W950XiWInzYTE4=;
        b=G4XyI8Vgz0s0VrkYhHIKUgDnm+igigSQchivao/pFfeY8eqUc2XarwtkvBPP12xAUF
         k3yxjPsrF9UEhNLtzdMgb+0o2mFqi3p4wWWKrC2SdXkB8nzcD2gYO+FfVNo2Ms2xoKKz
         KTg7cmr920K7xt6t7TJYPapRRduWAEq/hao4XwMHwvrvN+IgFIyxUy79nJesjOFn/0Qt
         D60D0+QYXTdXoOD4VWRgvBWTEEcPaYvgPPkDZobGcNqXntePBpo9FpdRXwUolEzP1zhU
         /jBdcCxeJn4bg4tVCAKAdYTwJ5zKjN1Rsi2Ey0rgUnQWW2jmiWS7aOW/XhIKO3s3pYe0
         /ARQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="cSYLQtG/";
       spf=pass (google.com: domain of 010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@amazonses.com
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id d19si2182037qvd.31.2019.03.07.19.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 19:08:41 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@amazonses.com designates 54.240.9.30 as permitted sender) client-ip=54.240.9.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b="cSYLQtG/";
       spf=pass (google.com: domain of 010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552014520;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=Qsyil3aA8gB2bCI9HRfEXGR5NVCprjsvM1XdMK95rKI=;
	b=cSYLQtG/NGkELqStS9fYnd9XGtShvawWekbQcHxUgiRa5T6ixwFOhU5nD7/h7oHL
	A2jHz+Ze6sUjCTS+pO+u1Uf6RyWBCp8BpLs/BfcPr54oLkXiDVO7P5am8S3zp9aHZ5f
	HO1EhnpUaH4gwXrGIlmtajbNx4EeV+TqJLxqegXw=
Date: Fri, 8 Mar 2019 03:08:40 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: john.hubbard@gmail.com
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190306235455.26348-1-jhubbard@nvidia.com>
Message-ID: <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.08-54.240.9.30
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Mar 2019, john.hubbard@gmail.com wrote:


> GUP was first introduced for Direct IO (O_DIRECT), allowing filesystem code
> to get the struct page behind a virtual address and to let storage hardware
> perform a direct copy to or from that page. This is a short-lived access
> pattern, and as such, the window for a concurrent writeback of GUP'd page
> was small enough that there were not (we think) any reported problems.
> Also, userspace was expected to understand and accept that Direct IO was
> not synchronized with memory-mapped access to that data, nor with any
> process address space changes such as munmap(), mremap(), etc.

It would good if that understanding would be enforced somehow given the problems
that we see.

> Interactions with file systems
> ==============================
>
> File systems expect to be able to write back data, both to reclaim pages,

Regular filesystems do that. But usually those are not used with GUP
pinning AFAICT.

> and for data integrity. Allowing other hardware (NICs, GPUs, etc) to gain
> write access to the file memory pages means that such hardware can dirty
> the pages, without the filesystem being aware. This can, in some cases
> (depending on filesystem, filesystem options, block device, block device
> options, and other variables), lead to data corruption, and also to kernel
> bugs of the form:

> Long term GUP
> =============
>
> Long term GUP is an issue when FOLL_WRITE is specified to GUP (so, a
> writeable mapping is created), and the pages are file-backed. That can lead
> to filesystem corruption. What happens is that when a file-backed page is
> being written back, it is first mapped read-only in all of the CPU page
> tables; the file system then assumes that nobody can write to the page, and
> that the page content is therefore stable. Unfortunately, the GUP callers
> generally do not monitor changes to the CPU pages tables; they instead
> assume that the following pattern is safe (it's not):
>
>     get_user_pages()
>
>     Hardware can keep a reference to those pages for a very long time,
>     and write to it at any time. Because "hardware" here means "devices
>     that are not a CPU", this activity occurs without any interaction
>     with the kernel's file system code.
>
>     for each page
>         set_page_dirty
>         put_page()
>
> In fact, the GUP documentation even recommends that pattern.

Isnt that pattern safe for anonymous memory and memory filesystems like
hugetlbfs etc? Which is the common use case.

> Anyway, the file system assumes that the page is stable (nothing is writing
> to the page), and that is a problem: stable page content is necessary for
> many filesystem actions during writeback, such as checksum, encryption,
> RAID striping, etc. Furthermore, filesystem features like COW (copy on
> write) or snapshot also rely on being able to use a new page for as memory
> for that memory range inside the file.
>
> Corruption during write back is clearly possible here. To solve that, one
> idea is to identify pages that have active GUP, so that we can use a bounce
> page to write stable data to the filesystem. The filesystem would work
> on the bounce page, while any of the active GUP might write to the
> original page. This would avoid the stable page violation problem, but note
> that it is only part of the overall solution, because other problems
> remain.

Yes you now have the filesystem as well as the GUP pinner claiming
authority over the contents of a single memory segment. Maybe better not
allow that?

> Direct IO
> =========
>
> Direct IO can cause corruption, if userspace does Direct-IO that writes to
> a range of virtual addresses that are mmap'd to a file.  The pages written
> to are file-backed pages that can be under write back, while the Direct IO
> is taking place.  Here, Direct IO races with a write back: it calls
> GUP before page_mkclean() has replaced the CPU pte with a read-only entry.
> The race window is pretty small, which is probably why years have gone by
> before we noticed this problem: Direct IO is generally very quick, and
> tends to finish up before the filesystem gets around to do anything with
> the page contents.  However, it's still a real problem.  The solution is
> to never let GUP return pages that are under write back, but instead,
> force GUP to take a write fault on those pages.  That way, GUP will
> properly synchronize with the active write back.  This does not change the
> required GUP behavior, it just avoids that race.

Direct IO on a mmapped file backed page doesnt make any sense. The direct
I/O write syscall already specifies one file handle of a filesystem that
the data is to be written onto.  Plus mmap already established another
second filehandle and another filesystem that is also in charge of that
memory segment.

Two filesystem trying to sync one memory segment both believing to have
exclusive access and we want to sort this out. Why? Dont allow this.

