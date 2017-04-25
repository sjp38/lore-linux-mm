Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 04F076B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:01:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 72so26889307pge.10
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 01:00:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s74si21434595pfs.386.2017.04.25.01.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 01:00:58 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3P7wxYt144678
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:00:58 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a22cdrkq2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:00:57 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 25 Apr 2017 09:00:55 +0100
Date: Tue, 25 Apr 2017 11:00:48 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Review request: draft ioctl_userfaultfd(2) manual page
References: <487b2c79-f99b-6d0f-2412-aa75cde65569@gmail.com>
 <9af29fc6-dce2-f729-0f07-a0bfcc6c3587@gmail.com>
 <20170322135423.GB27789@rapoport-lnx>
 <e8c5ca4a-0710-7206-b96e-10d171bda218@gmail.com>
 <20170421110714.GC20569@rapoport-lnx>
 <4c05c2bb-af77-d706-9455-8ceaa5510580@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c05c2bb-af77-d706-9455-8ceaa5510580@gmail.com>
Message-Id: <20170425080047.GA16770@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-man <linux-man@vger.kernel.org>

Hello Michael,

On Fri, Apr 21, 2017 at 01:41:18PM +0200, Michael Kerrisk (man-pages) wrote:
> Hi Mike,
> 

[...]

> > 
> > Yes.
> > Just the future is only a week or two from today as we are at 4.11-rc7 :)
> 
> Yes, I understand :-). So of course there's a *lot* more
> new stuff to document, right?

I've started to add the description of the new functionality to both
userfaultfd.2 and ioctl_userfaultfd.2 and it's somewhat difficult for me to
decide how it would be better to split the information between these two
pages and what should be the pages internal structure.

I even thought about possibility of adding relatively comprehensive
description of userfaultfd as man7/userfaultfd.7 and then keeping the pages
in man2 relatively small, just with brief description of APIs and SEE ALSO
pointing to man7.

Any advise is highly appreciated.
 
> [...]

--
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
