Received: from talaria.jf.intel.com (talaria.jf.intel.com [10.7.209.7])
	by hermes.jf.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id gAEMAIq17858
	for <linux-mm@kvack.org>; Thu, 14 Nov 2002 22:10:18 GMT
Received: from orsmsxvs040.jf.intel.com (orsmsxvs040.jf.intel.com [192.168.65.206])
	by talaria.jf.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.27 2002/10/16 23:46:59 dmccart Exp $) with SMTP id gAELxCe29088
	for <linux-mm@kvack.org>; Thu, 14 Nov 2002 21:59:12 GMT
Message-ID: <25282B06EFB8D31198BF00508B66D4FA03EA5AE0@fmsmsx114.fm.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Subject: RE: [patch] remove hugetlb syscalls
Date: Thu, 14 Nov 2002 14:12:06 -0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'William Lee Irwin III' <wli@holomorphy.com>, Rohit Seth <rseth@unix-os.sc.intel.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, "Seth, Rohit" <rohit.seth@intel.com>, dada1 <dada1@cosmosbay.com>, Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> -----Original Message-----
> From: William Lee Irwin III [mailto:wli@holomorphy.com] 
> > 
> On Thu, Nov 14, 2002 at 12:11:32PM -0800, Rohit Seth wrote:
> > This is not the problem with MAP_SHARED.  It is the lack of  (arch
> > specific) hugepage aligned function support in the kernel. 
> You can use 
> > the mmap on hugetlbfs using only MAP_FIXED with properly aligned 
> > addresses (but then this also is only a hint to kernel).  
> With addr == 
> > NULL in mmap, the function is bound to fail almost all the times.
> 
> There's very little standing in the way of automatic 
> placement. If in your opinion it should be implemented, I'll 
> add that feature today.
> 
mmap with addr==NULL is in my opinion a very useful thing.

> IIRC you mentioned you would like to export the arch-specific 
> hugepage-aligned vma placement functions; once these are 
> available, it should be trivial to reuse them.
> 
> 
I will export those functions from arch specific trees.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
