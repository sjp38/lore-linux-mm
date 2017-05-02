Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 304E86B0388
	for <linux-mm@kvack.org>; Tue,  2 May 2017 05:48:49 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y106so13139519wrb.14
        for <linux-mm@kvack.org>; Tue, 02 May 2017 02:48:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y51si19324551wry.96.2017.05.02.02.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 02:48:47 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v429i7Ma018064
	for <linux-mm@kvack.org>; Tue, 2 May 2017 05:48:46 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a6qn38hy2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 May 2017 05:48:46 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 2 May 2017 10:48:43 +0100
Date: Tue, 2 May 2017 12:48:37 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH man-pages 0/5] {ioctl_}userfaultfd.2: yet another update
References: <1493617399-20897-1-git-send-email-rppt@linux.vnet.ibm.com>
 <352eee49-d6d1-3e82-a558-2341484c81f3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <352eee49-d6d1-3e82-a558-2341484c81f3@gmail.com>
Message-Id: <20170502094836.GD5910@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On Mon, May 01, 2017 at 08:34:07PM +0200, Michael Kerrisk (man-pages) wrote:
> Hi Mike,
> 
> On 05/01/2017 07:43 AM, Mike Rapoport wrote:
> > Hi Michael,
> > 
> > These updates pretty much complete the coverage of 4.11 additions, IMHO.
> 
> Thanks for this, but we still await input from Andrea
> on various points.
> 
> > Mike Rapoport (5):
> >   ioctl_userfaultfd.2: update description of shared memory areas
> >   ioctl_userfaultfd.2: UFFDIO_COPY: add ENOENT and ENOSPC description
> >   ioctl_userfaultfd.2: add BUGS section
> >   userfaultfd.2: add note about asynchronios events delivery
> >   userfaultfd.2: update VERSIONS section with 4.11 chanegs
> > 
> >  man2/ioctl_userfaultfd.2 | 35 +++++++++++++++++++++++++++++++++--
> >  man2/userfaultfd.2       | 15 +++++++++++++++
> >  2 files changed, 48 insertions(+), 2 deletions(-)
> 
> I've applied all of the above, and done some light editing.
> 
> Could you please check my changes in the following commits:
> 
> 5191c68806c8ac73fdc89586cde434d2766abb5c
> 265225c1e2311ae26ead116e6c8d2cedd46144fa

Both are Ok
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
 
> Thanks,
> 
> Michael
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
