Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD5A6B02F4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:40:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p15so27719167pgs.7
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:40:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l66si1926517pfb.386.2017.06.27.06.40.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 06:40:04 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5RDd3ro088372
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:40:04 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bbk71f04j-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:40:03 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 27 Jun 2017 14:40:00 +0100
Date: Tue, 27 Jun 2017 16:39:53 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 0/5] userfaultfd: non-cooperative: syncronous events
References: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494930962-3318-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20170627133952.GA25343@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>

On Tue, May 16, 2017 at 01:35:57PM +0300, Mike Rapoport wrote:
> Hi,

Any comments on this?
Shall I repost without the "RFC" prefix?
 
> These patches add ability to generate userfaultfd events so that thier
> processing will be synchronized with the non-cooperative thread that caused
> the event.
> 
> In the non-cooperative case userfaultfd resumes execution of the thread
> that caused an event when the notification is read() by the uffd monitor.
> In some cases, like, for example, madvise(MADV_REMOVE), it might be
> desirable to keep the thread that caused the event suspended until the
> uffd monitor had the event handled.
> 
> The first two patches just shuffle the code a bit to make subsequent
> changes easier.
> The patches 3 and 4 create some unification in the way the threads are
> queued into waitqueues either after page fault or after a non-cooperative
> event.
> The fifth patch extends the userfaultfd API with an implementation of
> UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
> UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.
> 
> Mike Rapoport (5):
>   userfaultfd: introduce userfault_init_waitqueue helper
>   userfaultfd: introduce userfaultfd_should_wait helper
>   userfaultfd: non-cooperative: generalize wake key structure
>   userfaultfd: non-cooperative: use fault_pending_wqh for all events
>   userfaultfd: non-cooperative: allow synchronous EVENT_REMOVE
> 
>  fs/userfaultfd.c                 | 205 ++++++++++++++++++++++++---------------
>  include/uapi/linux/userfaultfd.h |  11 +++
>  2 files changed, 136 insertions(+), 80 deletions(-)
> 
> -- 
> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
