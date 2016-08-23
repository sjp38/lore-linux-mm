Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 476BD6B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 07:03:59 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so248755433pfg.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 04:03:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p2si3531053pae.30.2016.08.23.04.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 04:03:58 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7NB3s2h009130
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 07:03:58 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24y8tn9rfa-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 07:03:57 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 23 Aug 2016 12:03:33 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2DFA917D8063
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:05:16 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7NB3UMg25166206
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 11:03:30 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7NB3TWV031147
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 05:03:30 -0600
Date: Tue, 23 Aug 2016 14:03:26 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/1] soft_dirty: fix soft_dirty during THP split
References: <1471610515-30229-1-git-send-email-aarcange@redhat.com>
 <57B70796.4080408@virtuozzo.com>
 <20160819134303.35newk6bku5rjdlj@redhat.com>
 <57B70F33.9090902@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57B70F33.9090902@virtuozzo.com>
Message-Id: <20160823110325.GD1205@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mike Rapoport <mike.rapoport@gmail.com>

On Fri, Aug 19, 2016 at 04:52:51PM +0300, Pavel Emelyanov wrote:
> On 08/19/2016 04:43 PM, Andrea Arcangeli wrote:
> > On Fri, Aug 19, 2016 at 04:20:22PM +0300, Pavel Emelyanov wrote:
> >> And (!) after non-cooperative patches are functional too.
> > 
> > I merged your non-cooperative patches in my tree although there's no
> > testcase to exercise them yet.
> 
> Hm... Are you talking about some in-kernel test, or just any? We have
> tests in CRIU tree for UFFD (not sure we've wired up the non-cooperative
> part though).

Well, CRIU is by definition non-cooperative :)
Still, we don't have fork() and other events in CRIU lazy restore yet.
I have some brute force additions to the selftests/vm/userfaultfd.c that
verify that the events work, and I'm trying now to get a clean version.

BTW, with addition of hugetlbfs and tmpfs support to userfaultfd, we'd need
MADV_REMOVE and fallocate(PUNCH_HOLE) events in addition to
MADV_DONTNEED...
 
> > 
> > Thanks,
> > Andrea
> > .
> > 
> 
> -- Pavel
> 
--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
