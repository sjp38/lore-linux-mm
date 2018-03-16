Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50B7B6B0006
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:12:40 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a207so4773672qkb.23
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:12:40 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q184sor5930481qke.100.2018.03.16.12.12.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 12:12:39 -0700 (PDT)
Date: Fri, 16 Mar 2018 15:12:37 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH v9 13/61] xarray: Add documentation
Message-ID: <20180316191236.jsmlnwgy76htz5fi@destiny>
References: <20180313132639.17387-1-willy@infradead.org>
 <20180313132639.17387-14-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313132639.17387-14-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

On Tue, Mar 13, 2018 at 06:25:51AM -0700, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This is documentation on how to use the XArray, not details about its
> internal implementation.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

I'm just going to assume you know what you are talking about here

Acked-by: Josef Bacik <jbacik@fb.com>

Thanks,

Josef
