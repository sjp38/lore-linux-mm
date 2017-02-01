Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F59D6B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:37:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 80so549485508pfy.2
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:37:58 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d9si18255598pli.286.2017.01.31.22.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 22:37:57 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116XtwK091141
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 01:37:56 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28b22cy21r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:37:56 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 1 Feb 2017 06:37:54 -0000
Date: Wed, 1 Feb 2017 08:37:48 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2/5] userfaultfd: non-cooperative: add event for
 memory unmaps
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1485542673-24387-3-git-send-email-rppt@linux.vnet.ibm.com>
 <20170131163928.4e4e05fbd93358d9b937d79b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170131163928.4e4e05fbd93358d9b937d79b@linux-foundation.org>
Message-Id: <20170201063748.GB7921@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 31, 2017 at 04:39:28PM -0800, Andrew Morton wrote:
> On Fri, 27 Jan 2017 20:44:30 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > When a non-cooperative userfaultfd monitor copies pages in the background,
> > it may encounter regions that were already unmapped. Addition of
> > UFFD_EVENT_UNMAP allows the uffd monitor to track precisely changes in the
> > virtual memory layout.
> > 
> > Since there might be different uffd contexts for the affected VMAs, we
> > first should create a temporary representation for the unmap event for each
> > uffd context and then notify them one by one to the appropriate userfault
> > file descriptors.
> > 
> > The event notification occurs after the mmap_sem has been released.
> 
> I was going to bug you about not updating
> Documentation/vm/userfaultfd.txt but the UFFD_FEATURE flags aren't
> documented?
 
I'm going to send the documentation update in the next few days.

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
