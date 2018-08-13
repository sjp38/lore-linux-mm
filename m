Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA3DF6B0007
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 10:36:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t10-v6so6121508eds.7
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 07:36:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j4-v6si1340263edl.323.2018.08.13.07.36.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 07:36:27 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7DEUs2l066577
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 10:36:26 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ku9hexvk9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 10:36:25 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 13 Aug 2018 15:36:24 +0100
Date: Mon, 13 Aug 2018 17:36:19 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: memblock:What is the difference between memory and physmem?
References: <80B78A8B8FEE6145A87579E8435D78C3240515EF@FZEX4.ruijie.com.cn>
 <20180813023015.GB32733@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180813023015.GB32733@bombadil.infradead.org>
Message-Id: <20180813143619.GF769@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: yhb@ruijie.com.cn, linux-mm@kvack.org

On Sun, Aug 12, 2018 at 07:30:15PM -0700, Matthew Wilcox wrote:
> On Mon, Aug 13, 2018 at 02:23:26AM +0000, yhb@ruijie.com.cn wrote:
> > struct memblock {
> > bool bottom_up; /* is bottom up direction? */
> > phys_addr_t current_limit;
> > struct memblock_type memory;
> > struct memblock_type reserved;
> > #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> > struct memblock_type physmem;
> > #endif
> > };
> > What is the difference between memory and physmem?
> 
> commit 70210ed950b538ee7eb811dccc402db9df1c9be4
> Author: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
> Date:   Wed Jan 29 18:16:01 2014 +0100
> 
>     mm/memblock: add physical memory list
>     
>     Add the physmem list to the memblock structure. This list only exists
>     if HAVE_MEMBLOCK_PHYS_MAP is selected and contains the unmodified
>     list of physically available memory. It differs from the memblock
>     memory list as it always contains all memory ranges even if the
>     memory has been restricted, e.g. by use of the mem= kernel parameter.

And it is enabled only for s390
     
>     Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
>     Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 

-- 
Sincerely yours,
Mike.
