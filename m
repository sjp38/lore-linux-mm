Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id DFC526B0005
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:11:43 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y3so7265490qka.14
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:11:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j145sor5794314qke.163.2018.03.16.12.11.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 12:11:43 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:11:41 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v9 12/61] xarray: Define struct xa_node
Message-ID: <20180316191140.gscdlmgnhnzjssdo@destiny>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-13-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-13-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:50AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This is a direct replacement for struct radix_tree_node.  A couple of
> struct members have changed name, so convert those.  Use a #define so
> that radix tree users continue to work without change.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Reviewed-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
