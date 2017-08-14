Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78A406B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:58:12 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s14so115184555pgs.4
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 21:58:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l61si4136544plb.86.2017.08.13.21.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Aug 2017 21:58:11 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7E4rrav075505
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:58:10 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cb2m5nvd9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 00:58:09 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 14 Aug 2017 05:58:07 +0100
Date: Mon, 14 Aug 2017 07:58:03 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/5] userfaultfd: non-cooperative: syncronous events
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170627133952.GA25343@rapoport-lnx>
 <011e01d312a8$3c97e6b0$b5c7b410$@colorado.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <011e01d312a8$3c97e6b0$b5c7b410$@colorado.edu>
Message-Id: <20170814045802.GA18287@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Blake Caldwell <caldweba@colorado.edu>
Cc: 'Pavel Emelyanov' <xemul@virtuozzo.com>, 'linux-mm' <linux-mm@kvack.org>, 'Andrea Arcangeli' <aarcange@redhat.com>

Hi,

On Fri, Aug 11, 2017 at 09:46:29AM -0400, Blake Caldwell wrote:
> > On Tue, May 16, 2017 at 01:35:57PM +0300, Mike Rapoport wrote:
> > > Hi,
> > 
> > Any comments on this?
> > Shall I repost without the "RFC" prefix?
> > 
> I have a use case for this feature exactly like what you have described. The
> process should be suspended until the event has been handled. I would like
> to test this if there is a rebased patchset out there somewhere? I'm using
> 4.13.0_rc3 from
> https://kernel.googlesource.com/pub/scm/linux/kernel/git/andrea/aa.git
> 
> I wasn't able to apply the patches without heavy modification (mostly patch
> 3/5).

I don't have a version rebased on Andrea's tree, sorry.
 
> Thanks for the work on this.
> > > These patches add ability to generate userfaultfd events so that thier
> > > processing will be synchronized with the non-cooperative thread that
> > > caused the event.
> > >
> > > In the non-cooperative case userfaultfd resumes execution of the
> > > thread that caused an event when the notification is read() by the uffd
> > monitor.
> > > In some cases, like, for example, madvise(MADV_REMOVE), it might be
> > > desirable to keep the thread that caused the event suspended until the
> > > uffd monitor had the event handled.
> > >
> > > The first two patches just shuffle the code a bit to make subsequent
> > > changes easier.
> > > The patches 3 and 4 create some unification in the way the threads are
> > > queued into waitqueues either after page fault or after a
> > > non-cooperative event.
> > > The fifth patch extends the userfaultfd API with an implementation of
> > > UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
> > > UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.
> > >
> > > Mike Rapoport (5):
> > >   userfaultfd: introduce userfault_init_waitqueue helper
> > >   userfaultfd: introduce userfaultfd_should_wait helper
> > >   userfaultfd: non-cooperative: generalize wake key structure
> > >   userfaultfd: non-cooperative: use fault_pending_wqh for all events
> > >   userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE
> > >
> > >  fs/userfaultfd.c                 | 205
> ++++++++++++++++++++++++---------------
> > >  include/uapi/linux/userfaultfd.h |  11 +++
> > >  2 files changed, 136 insertions(+), 80 deletions(-)
> > >
> > > --
> > > 2.7.4
> > >
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
