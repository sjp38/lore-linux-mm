Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 172276B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:03:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id v19-v6so1825311eds.3
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:03:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f15-v6si3162932ede.13.2018.07.04.00.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 00:03:19 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w646x5vf057522
	for <linux-mm@kvack.org>; Wed, 4 Jul 2018 03:03:17 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k0n98ge23-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Jul 2018 03:03:15 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 4 Jul 2018 08:03:13 +0100
Date: Wed, 4 Jul 2018 10:03:06 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/memblock: replace u64 with phys_addr_t where
 appropriate
References: <1530637506-1256-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180703125722.6fd0f02b27c01f5684877354@linux-foundation.org>
 <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <063c785caa11b8e1c421c656b2a030d45d6eb68f.camel@perches.com>
Message-Id: <20180704070305.GB4352@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 03, 2018 at 01:24:07PM -0700, Joe Perches wrote:
> On Tue, 2018-07-03 at 12:57 -0700, Andrew Morton wrote:
> > Did you see all this checkpatch noise?
> > 
> > : WARNING: Deprecated vsprintf pointer extension '%pF' - use %pS instead
> > : #54: FILE: mm/memblock.c:1348:
> > : +	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
> > : +		     __func__, (u64)size, (u64)align, nid, &min_addr,
> > : +		     &max_addr, (void *)_RET_IP_);
> > : ...
> 
> %p[Ff] got deprecated by commit 04b8eb7a4ccd9ef9343e2720ccf2a5db8cfe2f67
> 
> I think it'd be simplest to just convert
> all the %pF and %pf uses all at once.
> 
> $ git grep --name-only "%p[Ff]" | \
>   xargs sed -i -e 's/%pF/%pS/' -e 's/%pf/%ps/'
> 
> and remove the appropriate Documentation bit.
> 

Something like this:
