Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1881E6B0343
	for <linux-mm@kvack.org>; Tue,  2 May 2017 05:33:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id l50so10672128wrc.18
        for <linux-mm@kvack.org>; Tue, 02 May 2017 02:33:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p111si18935854wrc.315.2017.05.02.02.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 02:33:07 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v42943oV098132
	for <linux-mm@kvack.org>; Tue, 2 May 2017 05:33:06 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2a6jut6sfs-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 May 2017 05:33:06 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 2 May 2017 10:33:04 +0100
Date: Tue, 2 May 2017 12:32:59 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH man-pages 3/5] ioctl_userfaultfd.2: add BUGS section
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1493617399-20897-4-git-send-email-rppt@linux.vnet.ibm.com>
 <345c064d-83fe-3e40-c5cb-5d4b6e5cdff4@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <345c064d-83fe-3e40-c5cb-5d4b6e5cdff4@gmail.com>
Message-Id: <20170502093252.GB5910@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Mon, May 01, 2017 at 08:33:50PM +0200, Michael Kerrisk (man-pages) wrote:
> Hi Mike,
> 
> I've applied this, but have a question.
> 
> On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> > The features handshake is not quite convenient.
> > Elaborate about it in the BUGS section.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  man2/ioctl_userfaultfd.2 | 9 +++++++++
> >  1 file changed, 9 insertions(+)
> > 
> > diff --git a/man2/ioctl_userfaultfd.2 b/man2/ioctl_userfaultfd.2
> > index e12b9de..50316de 100644
> > --- a/man2/ioctl_userfaultfd.2
> > +++ b/man2/ioctl_userfaultfd.2
> > @@ -650,6 +650,15 @@ operations are Linux-specific.
> >  .SH EXAMPLE
> >  See
> >  .BR userfaultfd (2).
> > +.SH BUGS
> > +In order to detect available userfault features and
> > +enable certain subset of those features
> 
> I changed "certain" to "some". ("certain subset" here also
> would sound like "some particular subset" of those features.)
> Okay?
 
Yes, sure.

> > +the usefault file descriptor must be closed after the first
> > +.BR UFFDIO_API
> > +operation that queries features availability and re-opened before
> > +the second
> > +.BR UFFDIO_API
> > +call that actually enables the desired features.
> >  .SH SEE ALSO
> >  .BR ioctl (2),
> >  .BR mmap (2),
> 
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
