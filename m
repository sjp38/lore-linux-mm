Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC0436B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:06:38 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h21so7117491qtm.22
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 11:06:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q36sor6270392qtf.5.2018.03.16.11.06.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 11:06:37 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:06:35 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v9 08/61] page cache: Use xa_lock
Message-ID: <20180316180633.e755emgeeovo4ddq@destiny>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-9-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-9-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:46AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Remove the address_space ->tree_lock and use the xa_lock newly added to
> the radix_tree_root.  Rename the address_space ->page_tree to ->i_pages,
> since we don't really care that it's a tree.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Acked-by: Jeff Layton <jlayton@redhat.com>

Man my eyes started to glaze over about halfway through this one

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
