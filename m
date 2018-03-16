Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E92866B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:00:04 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a143so7268649qkg.4
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:00:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i41sor5617698qti.99.2018.03.16.12.00.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 12:00:04 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:00:02 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v9 10/61] xarray: Change definition of sibling entries
Message-ID: <20180316190001.56clqrub6gy6lzh5@destiny>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-11-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-11-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:48AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Instead of storing a pointer to the slot containing the canonical entry,
> store the offset of the slot.  Produces slightly more efficient code
> (~300 bytes) and simplifies the implementation.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  include/linux/xarray.h | 93 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  lib/radix-tree.c       | 66 +++++++++++------------------------
>  2 files changed, 112 insertions(+), 47 deletions(-)
> 

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
