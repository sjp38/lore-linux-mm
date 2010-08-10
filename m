Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E218B60080E
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 16:21:43 -0400 (EDT)
Date: Wed, 11 Aug 2010 03:53:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/8] hugetlb: move definition of is_vm_hugetlb_page()
 to hugepage_inline.h
Message-ID: <20100810195342.GA6677@localhost>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1275006562-18946-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100528100350.GC9774@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528100350.GC9774@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > +#ifndef _LINUX_HUGETLB_INLINE_H
> > +#define _LINUX_HUGETLB_INLINE_H 1
> > +
> 
> Just #define __LINUX_HUGETLB_INLINE_H is fine. No need for the 1
> 
> > +#ifdef CONFIG_HUGETLBFS
> > +
> 
> Should be CONFIG_HUGETLB_PAGE
> 
> With those corrections;
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>

Both fixed in Andi's tree, so

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
