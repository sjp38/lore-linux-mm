Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 20A416B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:07:04 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ld10so713961pab.11
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 22:07:03 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id sw1si1758295pbc.162.2013.12.18.22.07.01
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 22:07:02 -0800 (PST)
Date: Thu, 19 Dec 2013 15:07:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3] mm/rmap: fix BUG at rmap_walk
Message-ID: <20131219060703.GA27787@lge.com>
References: <1387431715-6786-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131219055510.GA27532@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219055510.GA27532@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 19, 2013 at 02:55:10PM +0900, Joonsoo Kim wrote:
> On Thu, Dec 19, 2013 at 01:41:55PM +0800, Wanpeng Li wrote:
> > This bug is introduced by commit 37f093cdf(mm/rmap: use rmap_walk() in 
> > page_referenced()). page_get_anon_vma() called in page_referenced_anon() 
> > will lock and increase the refcount of anon_vma. PageLocked is not required 
> > by page_referenced_anon() and there is not any assertion before, commit 
> > 37f093cdf introduced this extra BUG_ON() checking for anon page by mistake.
> > This patch fix it by remove rmap_walk()'s VM_BUG_ON() and comment reason why 
> > the page must be locked for rmap_walk_ksm() and rmap_walk_file().

FYI.

See following link to get more information.

https://lkml.org/lkml/2004/7/12/241

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
