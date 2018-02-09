Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD296B000E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 05:57:47 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f34so6336514qtb.4
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 02:57:47 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t5si1962193qtn.185.2018.02.09.02.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 02:57:46 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w19Asb35084359
	for <linux-mm@kvack.org>; Fri, 9 Feb 2018 05:57:45 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2g1924bd7d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Feb 2018 05:57:45 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 9 Feb 2018 10:57:44 -0000
Date: Fri, 9 Feb 2018 12:57:37 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/zpool: zpool_evictable: fix mismatch in parameter
 name and kernel-doc
References: <1518116984-21141-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1a8a3fb7-3061-d9e7-a42c-53ae96c8ca29@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a8a3fb7-3061-d9e7-a42c-53ae96c8ca29@infradead.org>
Message-Id: <20180209105736.GA2044@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, Feb 08, 2018 at 11:17:33AM -0800, Randy Dunlap wrote:
> On 02/08/2018 11:09 AM, Mike Rapoport wrote:
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> >  mm/zpool.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/zpool.c b/mm/zpool.c
> > index f8cb83e7699b..9d53a1ef8f1e 100644
> > --- a/mm/zpool.c
> > +++ b/mm/zpool.c
> > @@ -360,7 +360,7 @@ u64 zpool_get_total_size(struct zpool *zpool)
> >  
> >  /**
> >   * zpool_evictable() - Test if zpool is potentially evictable
> > - * @pool	The zpool to test
> > + * @zpool	The zpool to test
> 
>   + * @zpool:	The zpool to test
 
Thanks!

> >   *
> >   * Zpool is only potentially evictable when it's created with struct
> >   * zpool_ops.evict and its driver implements struct zpool_driver.shrink.
> > 
> 
> 
> -- 
> ~Randy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
