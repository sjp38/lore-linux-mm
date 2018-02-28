Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0AB6B0006
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:26:25 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id g13so1457063qtj.15
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 00:26:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y36si1308989qtj.99.2018.02.28.00.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Feb 2018 00:26:24 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w1S8QH7d082165
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:26:23 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gdqaeku6a-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 03:26:23 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 28 Feb 2018 08:26:19 -0000
Date: Wed, 28 Feb 2018 10:26:14 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] userfaultfd: non-cooperative: allow synchronous
 EVENT_REMOVE
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1519719592-22668-4-git-send-email-rppt@linux.vnet.ibm.com>
 <1a2ed216-74ac-5fe2-abff-21d670eeb96d@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a2ed216-74ac-5fe2-abff-21d670eeb96d@virtuozzo.com>
Message-Id: <20180228082613.GD15048@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>

On Wed, Feb 28, 2018 at 11:21:02AM +0300, Pavel Emelyanov wrote:
> 
> > @@ -52,6 +53,7 @@
> >  #define _UFFDIO_WAKE			(0x02)
> >  #define _UFFDIO_COPY			(0x03)
> >  #define _UFFDIO_ZEROPAGE		(0x04)
> > +#define _UFFDIO_WAKE_SYNC_EVENT		(0x05)
> 
> Excuse my ignorance, but what's the difference between UFFDIO_WAKE and UFFDIO_WAKE_SYNC_EVENT?

UFFDIO_WAKE is used when UFFDIO_COPY/UFFDIO_ZERO page are used with
UFFDIO_*_MODE_DONTWAKE flag set and it presumes 'struct uffdio_range'
argument to the ioctl(). Since waking up a non page fault event requires
different parameters I've add new ioctl to keep backwards compatibility.
 
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
