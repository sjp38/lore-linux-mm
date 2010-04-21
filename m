Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A483C6B01FD
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 17:11:08 -0400 (EDT)
Date: Wed, 21 Apr 2010 23:10:52 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] ksm: check for ERR_PTR from follow_page()
Message-ID: <20100421211052.GE5336@cmpxchg.org>
References: <20100421102759.GA29647@bicker> <4BCF18A8.8080809@redhat.com> <20100421174615.GO32034@random.random> <20100421205305.GO20640@cmpxchg.org> <20100421205807.GV32034@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100421205807.GV32034@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Dan Carpenter <error27@gmail.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 10:58:07PM +0200, Andrea Arcangeli wrote:
> On Wed, Apr 21, 2010 at 10:53:05PM +0200, Johannes Weiner wrote:
> > + * Returns the mapped (struct page *), %NULL if no mapping exists, or
> > + * an error pointer if there is a mapping to something not represented
> > + * by a page descriptor (see also vm_normal_page()).
> 
> where exactly in vm_normal_page? Note I already checked vm_normal_page
> before sending the prev email and I didn't immediately see.  I search
> return and they all return NULL except the return pfn_to_page(pfn), so
> is pfn_to_page that returns -EFAULT (the implementations I checked
> don't but there are plenty that I didn't check...).

It's not vm_normal_page() that returns -EFAULT.  It is follow_page()
that translates NULL from vm_normal_page() into -EFAULT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
