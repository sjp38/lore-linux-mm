Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF4376B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:05:35 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id e205so2947588qkb.8
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:05:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s3sor6479500qte.153.2018.03.16.12.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 12:05:34 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:05:33 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v9 11/61] xarray: Add definition of struct xarray
Message-ID: <20180316190531.kpepu5eaimnnixf5@destiny>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-12-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-12-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:49AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This is a direct replacement for struct radix_tree_root.  Some of the
> struct members have changed name; convert those, and use a #define so
> that radix_tree users continue to work without change.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
