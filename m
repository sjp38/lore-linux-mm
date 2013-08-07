Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id D0AB86B0033
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 16:29:17 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id w20so1879424lbh.19
        for <linux-mm@kvack.org>; Wed, 07 Aug 2013 13:29:15 -0700 (PDT)
Date: Thu, 8 Aug 2013 00:29:14 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130807202914.GO7999@moon>
References: <20130730204154.407090410@gmail.com>
 <20130730204654.844299768@gmail.com>
 <20130807132156.e97bbcc3d543cf88d5a0997d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807132156.e97bbcc3d543cf88d5a0997d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Wed, Aug 07, 2013 at 01:21:56PM -0700, Andrew Morton wrote:
> > 
> > One of the problem was to find a place in pte entry where we can
> > save the _PTE_SWP_SOFT_DIRTY bit while page is in swap. The
> > _PAGE_PSE was chosen for that, it doesn't intersect with swap
> > entry format stored in pte.
> 
> So the implication is that if another architecture wants to support
> this (and, realistically, wants to support CRIU), that architecture
> must find a spare pte bit to implement _PTE_SWP_SOFT_DIRTY.  Yes?

Exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
