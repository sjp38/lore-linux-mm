Return-Path: <SRS0=SdaL=XB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60755C43140
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 086B820854
	for <linux-mm@archiver.kernel.org>; Fri,  6 Sep 2019 12:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 086B820854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47F706B0003; Fri,  6 Sep 2019 08:39:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42F0B6B0006; Fri,  6 Sep 2019 08:39:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344FA6B0007; Fri,  6 Sep 2019 08:39:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 12EF16B0003
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 08:39:10 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 914CB610C
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:39:09 +0000 (UTC)
X-FDA: 75904450818.30.paste40_4fd3db5765d01
X-HE-Tag: paste40_4fd3db5765d01
X-Filterd-Recvd-Size: 9620
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:39:08 +0000 (UTC)
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3702E11A1A
	for <linux-mm@kvack.org>; Fri,  6 Sep 2019 12:39:07 +0000 (UTC)
Received: by mail-pf1-f198.google.com with SMTP id u3so3591059pfm.4
        for <linux-mm@kvack.org>; Fri, 06 Sep 2019 05:39:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=m0d6g/jUPu62S9xgeNV/xZh0N5kxmPK9Bnnmm3qnIlA=;
        b=QgQ+nQkxgJbeLOdcU/6oVsG13OMQR++Xl33iIFkEipVJJkpS1MgwnWBMK0nn+TvWbq
         eKQnPeLY2r3g0NQvFB1V2h1YUfL0xm3A0gFYXfIk0VRoxE5XgJn9oKcILbWG5zwbuTw4
         2kewFI/jwa4wQTYqaXW9RvgzBzFrjfdOOB3+YVIA9lu46due8PwqAEaErGl2JXNVex1s
         zYz4+zrIM1L0QU9oEXPpJqvfAtGT6Q/rYykxtdDyeaX4/blMyQBSMB1GhbfYc4his9ai
         EOmVGU+NoE/ME9axpJ1HrqzkYcO9h4hs68x4GSb8AhQguf0szjFhuSOw3h9Kc2HPdz5E
         9fow==
X-Gm-Message-State: APjAAAUzsFig7n+UmdLELfFYyzcEb5fkwaU/7k6NJhma6dDw7TKCx/qY
	L+LeoW6SMCVjELVJl9X+0ao1dr2y7K+rAWITr8qm1/aGqmYQQkSwHh6lG7/45FZrCdVfz6J5Fdh
	QHPDkgoNB1Sk=
X-Received: by 2002:a17:90a:d354:: with SMTP id i20mr9429216pjx.49.1567773546622;
        Fri, 06 Sep 2019 05:39:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlArPS7zuifCx0mcEd1x8jUCna7XshukrVRfvCdHhJIKRK9tKPzoKErzHMeZE7l/QILpTC9w==
X-Received: by 2002:a17:90a:d354:: with SMTP id i20mr9429191pjx.49.1567773546300;
        Fri, 06 Sep 2019 05:39:06 -0700 (PDT)
Received: from xz-x1 ([209.132.188.80])
        by smtp.gmail.com with ESMTPSA id 71sm10193872pfw.147.2019.09.06.05.38.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Sep 2019 05:39:05 -0700 (PDT)
Date: Fri, 6 Sep 2019 20:38:51 +0800
From: Peter Xu <peterx@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Marty McFadden <mcfadden8@llnl.gov>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 3/7] mm: Introduce FAULT_FLAG_INTERRUPTIBLE
Message-ID: <20190906123851.GB8813@xz-x1>
References: <20190905101534.9637-1-peterx@redhat.com>
 <20190905101534.9637-4-peterx@redhat.com>
 <0d45ffaf-0588-a068-d361-6a9cb6c71413@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <0d45ffaf-0588-a068-d361-6a9cb6c71413@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 11:02:22AM +0200, David Hildenbrand wrote:
> On 05.09.19 12:15, Peter Xu wrote:
> > handle_userfaultfd() is currently the only one place in the kernel
> > page fault procedures that can respond to non-fatal userspace signals.
> > It was trying to detect such an allowance by checking against USER &
> > KILLABLE flags, which was "un-official".
> > 
> > In this patch, we introduced a new flag (FAULT_FLAG_INTERRUPTIBLE) to
> > show that the fault handler allows the fault procedure to respond even
> > to non-fatal signals.  Meanwhile, add this new flag to the default
> > fault flags so that all the page fault handlers can benefit from the
> > new flag.  With that, replacing the userfault check to this one.
> > 
> > Since the line is getting even longer, clean up the fault flags a bit
> > too to ease TTY users.
> > 
> > Although we've got a new flag and applied it, we shouldn't have any
> > functional change with this patch so far.
> > 
> > Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  fs/userfaultfd.c   |  4 +---
> >  include/linux/mm.h | 39 ++++++++++++++++++++++++++++-----------
> >  2 files changed, 29 insertions(+), 14 deletions(-)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index ccbdbd62f0d8..4a8ad2dc2b6f 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -462,9 +462,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
> >  	uwq.ctx = ctx;
> >  	uwq.waken = false;
> >  
> > -	return_to_userland =
> > -		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
> > -		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);
> > +	return_to_userland = vmf->flags & FAULT_FLAG_INTERRUPTIBLE;
> >  	blocking_state = return_to_userland ? TASK_INTERRUPTIBLE :
> >  			 TASK_KILLABLE;
> >  
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 57fb5c535f8e..53ec7abb8472 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -383,22 +383,38 @@ extern unsigned int kobjsize(const void *objp);
> >   */
> >  extern pgprot_t protection_map[16];
> >  
> > -#define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
> > -#define FAULT_FLAG_MKWRITE	0x02	/* Fault was mkwrite of existing pte */
> > -#define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
> > -#define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
> > -#define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
> > -#define FAULT_FLAG_TRIED	0x20	/* Second try */
> > -#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
> > -#define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
> > -#define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
> > +/**
> > + * Fault flag definitions.
> > + *
> > + * @FAULT_FLAG_WRITE: Fault was a write fault.
> > + * @FAULT_FLAG_MKWRITE: Fault was mkwrite of existing PTE.
> > + * @FAULT_FLAG_ALLOW_RETRY: Allow to retry the fault if blocked.
> > + * @FAULT_FLAG_RETRY_NOWAIT: Don't drop mmap_sem and wait when retrying.
> > + * @FAULT_FLAG_KILLABLE: The fault task is in SIGKILL killable region.
> > + * @FAULT_FLAG_TRIED: The fault has been tried once.
> > + * @FAULT_FLAG_USER: The fault originated in userspace.
> > + * @FAULT_FLAG_REMOTE: The fault is not for current task/mm.
> > + * @FAULT_FLAG_INSTRUCTION: The fault was during an instruction fetch.
> > + * @FAULT_FLAG_INTERRUPTIBLE: The fault can be interrupted by non-fatal signals.
> > + */
> > +#define FAULT_FLAG_WRITE			0x01
> > +#define FAULT_FLAG_MKWRITE			0x02
> > +#define FAULT_FLAG_ALLOW_RETRY			0x04
> > +#define FAULT_FLAG_RETRY_NOWAIT			0x08
> > +#define FAULT_FLAG_KILLABLE			0x10
> > +#define FAULT_FLAG_TRIED			0x20
> > +#define FAULT_FLAG_USER				0x40
> > +#define FAULT_FLAG_REMOTE			0x80
> > +#define FAULT_FLAG_INSTRUCTION  		0x100
> > +#define FAULT_FLAG_INTERRUPTIBLE		0x200
> >  
> 
> I'd probably split off the unrelated doc changes. Just a matter of taste.

The thing is that it's not really a document change but only a format
change (when I wanted to add the new macro it's easily getting out of
80 chars so I simply reformatted all the rest to make them look
similar).  I'm afraid that could be too trivial to change the format
as a single patch, but I can do it if anyone else also thinks it
proper.

> 
> >  /*
> >   * The default fault flags that should be used by most of the
> >   * arch-specific page fault handlers.
> >   */
> >  #define FAULT_FLAG_DEFAULT  (FAULT_FLAG_ALLOW_RETRY | \
> > -			     FAULT_FLAG_KILLABLE)
> > +			     FAULT_FLAG_KILLABLE | \
> > +			     FAULT_FLAG_INTERRUPTIBLE)
> 
> So by default, all faults are marked interruptible, also
> !FAULT_FLAG_USER. I assume the trick right now is that
> handle_userfault() will indeed only be called on user faults and the
> flag is used nowhere else ;)

Sorry if this is confusing, but FAULT_FLAG_DEFAULT is just a macro to
make the patchset easier so we define this initial flags for most of
the archs (say, there can be some arch that does not use this default
value, but the fact is most archs are indeed using the same flags
hence we define it here now).

And, userfaultfd can also handle kernel faults.  For FAULT_FLAG_USER,
it will be set if the fault comes from userspace (in
do_user_addr_fault()).

> 
> Would it make sense to name it FAULT_FLAG_USER_INTERRUPTIBLE, to stress
> that the flag only applies to user faults? (or am I missing something
> and this could also apply to !user faults somewhen in the future?

As mentioned above, uffd can handle kernel faults.  And, for what I
understand, it's not really directly related to user fault or not at
all, instead its more or less match with TASK_{INTERRUPTIBLE|KILLABLE}
on what kind of signals we care about during the fault processing.  So
it seems to me that it's two different things.

> 
> (I am no expert on the fault paths yet, so sorry for the silly questions)

(I only hope that I'm not providing silly answers. :)

Thanks,

-- 
Peter Xu

