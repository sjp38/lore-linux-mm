Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65AD06B0316
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 02:31:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y77so13184765pfd.2
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 23:31:05 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id a1si661658plt.99.2017.09.11.23.31.03
        for <linux-mm@kvack.org>;
        Mon, 11 Sep 2017 23:31:04 -0700 (PDT)
Date: Tue, 12 Sep 2017 15:31:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm:swap: skip swapcache for swapin of synchronous
 device
Message-ID: <20170912063102.GA2068@bbox>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
 <1505183833-4739-5-git-send-email-minchan@kernel.org>
 <20170912060456.GA703@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170912060456.GA703@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>

On Tue, Sep 12, 2017 at 03:04:56PM +0900, Sergey Senozhatsky wrote:
> On (09/12/17 11:37), Minchan Kim wrote:
> > +		} else {
> > +			/* skip swapcache */
> > +			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
> 
> what if alloc_page_vma() fails?

Several modifications during development finally makes me remove the NULL check.
Thanks for catching it as well as style fix-up of other patch, Sergey.
