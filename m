Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BEFF6B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 10:22:23 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e22-v6so3947520ita.0
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:22:23 -0700 (PDT)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [96.114.154.165])
        by mx.google.com with ESMTPS id m20-v6si1446926itm.161.2018.04.10.07.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 07:22:22 -0700 (PDT)
Date: Tue, 10 Apr 2018 09:21:20 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180410125351.15837-1-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1804100920110.27333@nuc-kabylake>
References: <20180410125351.15837-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> __GFP_ZERO requests that the object be initialised to all-zeroes,
> while the purpose of a constructor is to initialise an object to a
> particular pattern.  We cannot do both.  Add a warning to catch any
> users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> a constructor.

Can we move this check out of the critical paths and check for
a ctor and GFP_ZERO when calling the page allocator? F.e. in
allocate_slab()?
