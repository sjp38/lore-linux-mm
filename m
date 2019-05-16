Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76065C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:14:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 274D420848
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:14:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fReDa0z9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 274D420848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C82856B0005; Thu, 16 May 2019 09:14:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C33766B0006; Thu, 16 May 2019 09:14:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFA4A6B0007; Thu, 16 May 2019 09:14:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 859F66B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:14:36 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d9so1367683oia.16
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:14:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ROaA0wXtesoRLV9jmYQxe8dOtv7TkiCY5hrIvCy7dF4=;
        b=n2B/1OzX6kmdZ2XvWfR1ya0oB1hgo7suG+QBCta4xZIcSqI47yPw1ES7Xx4aCnm5QJ
         29q1ctvcEzzVbyt8if3VE3NWX7HXfsZC2iX+xXaZJqiXm3sq36+3W9LViXikXFF2ai1p
         6DhC8RhqIvcsSu28/icqR11A0j7wG/w42+LWb5vVE5RUcB0pGNdtX4OUgFhhx1E1/TUB
         P3QW+Spe5tTk1oC41ETngRjx7X3Dfx7noyY7i/LhgdQInqhOuRGcCvwYIMqvOJHBiKTo
         cyA1bFr93zZGSMLlani8rzzt69VF/uE7vMioeUBX9PJton1ox1oSjXnuGaMtj6otr4ba
         GHOA==
X-Gm-Message-State: APjAAAW4JZCqV3+XZ4OvJFiY/lCyVUx4U/sEPZeAzTnUeGv3tDjxALSm
	QBOWaTr6At8ak/GmvKoE8zbedccs5sgnoYjlrZJHSINyWGttOAqAxC+L7d40Eg6LiUmDQqGXBTj
	8I6x9l5Rao8OCIi8aci9VMDF0ELmqO1nka8RY/rmQllgxV2kL77bYQf6lnAtzXFQgWQ==
X-Received: by 2002:a9d:7657:: with SMTP id o23mr30286454otl.358.1558012476122;
        Thu, 16 May 2019 06:14:36 -0700 (PDT)
X-Received: by 2002:a9d:7657:: with SMTP id o23mr30286408otl.358.1558012475440;
        Thu, 16 May 2019 06:14:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558012475; cv=none;
        d=google.com; s=arc-20160816;
        b=okkZtAFyIHe2NdL5pSNXyLUczXf5sHcuRennAn514Y7wz8ZK3/DlOwXzOLHDeGlh1v
         Ga/81oKCA4S6YRURDUr47XBt7Z13csBXG30i3cKHnbDBaU/jk6GZTLVc3Z+DGoUXJiqS
         eS1+u5t6d32Y2Azkv/bzURNmBMLhZErWmpupqxBP0qSe5UJyQ3OXJPEHomTeHn3il04D
         I1aGjabLBb95XtnSeMI4gKd1r8SAYfuVw+truJdNTqI11eSqxLrshg6xhSsSAp7QK+Ff
         0zz69Qmx7qSwqujrsY3l94+KIf0UCjG2euB3TqGY2J4e2WhceJHbLC3k46pTsYoYmLM6
         sHjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ROaA0wXtesoRLV9jmYQxe8dOtv7TkiCY5hrIvCy7dF4=;
        b=wmJGRLvvCT+68+MIlcoFbzpN9xQI2ym9v0DMlCuUTxzon0LCHDbDCigfcGHiZMNWM1
         6Svlv0giZrfV+Z0B8tv4OdNcCPl9x1H8CGlzmEhYWtrnQJUE+DJCLWlRuQQPKxJ3SVW3
         xZyY7tjd8auy8yMcLtdyrRM4urORXOEGjvqpXoO9NvAuA2dXtCVVpwBX1r2KQn9RMIcX
         lZCK3DjGpb7nwYNbouJL0fIREMiALw78drPEOEAWANZVCSKqhDspcU344HBUkGmXJ5fZ
         bE7e+JpIWYXwok11KcJUSoS3By7RoRoqGM9mbjjakO6gtnQpIrUdfRuZ9nDpkPBwpqM1
         JNbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fReDa0z9;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor2665139oto.178.2019.05.16.06.14.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 06:14:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fReDa0z9;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ROaA0wXtesoRLV9jmYQxe8dOtv7TkiCY5hrIvCy7dF4=;
        b=fReDa0z9uHf+JdOnFb05L1Sb2NczVkeE/wfdtsKJtVRJdlu/Fy7TPQQlZVllJGEfVI
         RGg7FWvRbo8E6AVP8MLFTeXB72jglZuZienY2l/zowEbQoOpIBaa/+jFnlle3GzGFc3X
         xNigM0FnR9XrDOEY5QID9N8l7rr1SPmrT5PfodS5GKNfnFOfOth2NQIDjT3rgcY+M3vB
         Cfuq7MjGvfW0ty3Bhj2YvrKqrFz97mPOyFCFMPTS0hiLi4mZ+3MOlRoB3Jehl3WmsUD2
         iBrqKjQNY+qEgbDG40juKK/o/hmnoDNXWF12m1KsESJx4v2wbFNzxs5C0nwXyl5NB/mP
         /Q/Q==
X-Google-Smtp-Source: APXvYqz8ONif2CczL0twdpVOaBW6vNrGkKqpu7xEjjDuQ4L9r3lh6OrdS3yiomN/QUeXmHuUGmjDQ0jYNaDLm4icWVQ=
X-Received: by 2002:a9d:6954:: with SMTP id p20mr8910155oto.337.1558012474998;
 Thu, 16 May 2019 06:14:34 -0700 (PDT)
MIME-Version: 1.0
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <CAG48ez20Nu76Q8Tye9Hd3HGCmvfUYH+Ubp2EWbnhLp+J6wqRvw@mail.gmail.com> <456c7367-0656-933b-986d-febdcc5ab98e@virtuozzo.com>
In-Reply-To: <456c7367-0656-933b-986d-febdcc5ab98e@virtuozzo.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 16 May 2019 15:14:08 +0200
Message-ID: <CAG48ez0itiEE1x=SXeMbjKvMGkrj7wxjM6c+ZB00LpXAAhqmiw@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Michal Hocko <mhocko@suse.com>, keith.busch@intel.com, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, ira.weiny@intel.com, 
	Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org, 
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@surriel.com>, 
	Kees Cook <keescook@chromium.org>, hannes@cmpxchg.org, npiggin@gmail.com, 
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Shakeel Butt <shakeelb@google.com>, 
	Roman Gushchin <guro@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Jerome Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, 
	daniel.m.jordan@oracle.com, kernel list <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 3:03 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> On 15.05.2019 21:46, Jann Horn wrote:
> > On Wed, May 15, 2019 at 5:11 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >> This patchset adds a new syscall, which makes possible
> >> to clone a mapping from a process to another process.
> >> The syscall supplements the functionality provided
> >> by process_vm_writev() and process_vm_readv() syscalls,
> >> and it may be useful in many situation.
> >>
> >> For example, it allows to make a zero copy of data,
> >> when process_vm_writev() was previously used:
> > [...]
> >> This syscall may be used for page servers like in example
> >> above, for migration (I assume, even virtual machines may
> >> want something like this), for zero-copy desiring users
> >> of process_vm_writev() and process_vm_readv(), for debug
> >> purposes, etc. It requires the same permittions like
> >> existing proc_vm_xxx() syscalls have.
> >
> > Have you considered using userfaultfd instead? userfaultfd has
> > interfaces (UFFDIO_COPY and UFFDIO_ZERO) for directly shoving pages
> > into the VMAs of other processes. This works without the churn of
> > creating and merging VMAs all the time. userfaultfd is the interface
> > that was written to support virtual machine migration (and it supports
> > live migration, too).
>
> I know about userfaultfd, but it does solve the discussed problem.
> It allocates new pages to make UFFDIO_COPY (see mcopy_atomic_pte()),
> and it accumulates all the disadvantages, the example from [0/5]
> message has.

Sorry, right, I misremembered that.

