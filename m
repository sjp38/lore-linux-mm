Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D79686B0317
	for <linux-mm@kvack.org>; Tue,  2 May 2017 05:31:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i7so1004348wmf.19
        for <linux-mm@kvack.org>; Tue, 02 May 2017 02:31:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t190si505665wme.72.2017.05.02.02.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 02:31:27 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4294Jqp125322
	for <linux-mm@kvack.org>; Tue, 2 May 2017 05:31:26 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a6g76d8fk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 May 2017 05:31:26 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 2 May 2017 10:31:23 +0100
Date: Tue, 2 May 2017 12:31:11 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH man-pages 1/5] ioctl_userfaultfd.2: update description of
 shared memory areas
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-2-git-send-email-rppt@linux.vnet.ibm.com>
 <7ec5dfc0-9d84-e142-bfaa-d96383acbee9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7ec5dfc0-9d84-e142-bfaa-d96383acbee9@gmail.com>
Message-Id: <20170502093110.GA5910@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Mon, May 01, 2017 at 08:33:31PM +0200, Michael Kerrisk (man-pages) wrote:
> Hello Mike,
> 
> I've applied this patch, but  have a question.
> 
> On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  man2/ioctl_userfaultfd.2 | 13 +++++++++++--
> >  1 file changed, 11 insertions(+), 2 deletions(-)
> > 
> > diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> > index 889feb9..6edd396 100644
> > --- a/man2/ioctl_userfaultfd.2
> > +++ b/man2/ioctl_userfaultfd.2
> > @@ -181,8 +181,17 @@ virtual memory areas
> >  .TP
> >  .B UFFD_FEATURE_MISSING_SHMEM
> >  If this feature bit is set,
> > -the kernel supports registering userfaultfd ranges on tmpfs
> > -virtual memory areas
> > +the kernel supports registering userfaultfd ranges on shared memory areas.
> > +This includes all kernel shared memory APIs:
> > +System V shared memory,
> > +tmpfs,
> > +/dev/zero,
> > +.BR mmap(2)
> > +with
> > +.I MAP_SHARED
> > +flag set,
> > +.BR memfd_create (2),
> > +etc.
> >  
> >  The returned
> >  .I ioctls
> 
> Does the change in this patch represent a change that occurred in
> Linux 4.11? If so, I think this needs to be said explicitly in the text.

The patch only extends the description of UFFD_FEATURE_MISSING_SHMEM. The
feature is indeed available from 4.11, but that is said a few lives above
(line 136 in ioctl_userfaultfd.2)
 
> Cheers,
> 
> Michael
> 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
