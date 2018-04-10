Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83D006B0028
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:53:09 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n51so8464435qta.9
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 06:53:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6sor2087026qke.31.2018.04.10.06.53.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 06:53:08 -0700 (PDT)
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
References: <20180410125351.15837-1-willy@infradead.org>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com>
Date: Tue, 10 Apr 2018 06:53:04 -0700
MIME-Version: 1.0
In-Reply-To: <20180410125351.15837-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org



On 04/10/2018 05:53 AM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> __GFP_ZERO requests that the object be initialised to all-zeroes,
> while the purpose of a constructor is to initialise an object to a
> particular pattern.  We cannot do both.  Add a warning to catch any
> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> a constructor.
> 
> Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: stable@vger.kernel.org


Since there are probably no bug to fix, what about adding the extra check
only for some DEBUG option ?

How many caches are still using ctor these days ?
