Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 20FC96B002B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 06:27:53 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 27 Aug 2012 11:27:50 +0100
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7RARf1g10223690
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 10:27:41 GMT
Received: from d06av08.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7RARj8L002140
	for <linux-mm@kvack.org>; Mon, 27 Aug 2012 04:27:47 -0600
Date: Mon, 27 Aug 2012 12:27:42 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [RFC patch 2/7] thp: introduce pmdp_invalidate()
Message-ID: <20120827122742.1281aba4@thinkpad>
In-Reply-To: <CAJd=RBBQJCxgdrEnAdoVu+PLjkzTOBnDyJX_bqUdbQdo5TQoJw@mail.gmail.com>
References: <20120823171733.595087166@de.ibm.com>
	<20120823171854.473831303@de.ibm.com>
	<CAJd=RBBQJCxgdrEnAdoVu+PLjkzTOBnDyJX_bqUdbQdo5TQoJw@mail.gmail.com>
Reply-To: gerald.schaefer@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Sat, 25 Aug 2012 20:36:37 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Fri, Aug 24, 2012 at 1:17 AM, Gerald Schaefer
> <gerald.schaefer@de.ibm.com> wrote:
> 
> > +#ifndef __HAVE_ARCH_PMDP_INVALIDATE
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +static inline void pmdp_invalidate(struct vm_area_struct *vma,
> > +                                  unsigned long address, pmd_t *pmdp)
> > +{
> > +       set_pmd_at(vma->vm_mm, address, pmd, pmd_mknotpresent(*pmd));
> 
> 	set_pmd_at(vma->vm_mm, address, pmdp, pmd_mknotpresent(*pmdp));  yes?

Ah yes, I mixed that up, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
