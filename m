Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E13FD6B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 17:42:26 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id x97so5881925wrb.3
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 14:42:26 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f190sor675203wmf.74.2018.03.09.14.42.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 14:42:25 -0800 (PST)
Date: Sat, 10 Mar 2018 01:42:22 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 12/25] slub: make ->reserved unsigned int
Message-ID: <20180309224222.GD3843@avx2>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180305200730.15812-12-adobriyan@gmail.com>
 <20180306184508.GA11216@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180306184508.GA11216@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 10:45:08AM -0800, Matthew Wilcox wrote:
> On Mon, Mar 05, 2018 at 11:07:17PM +0300, Alexey Dobriyan wrote:
> > ->reserved is either 0 or sizeof(struct rcu_head), can't be negative.
> 
> Maybe make it unsigned char instead of unsigned int in case there's
> anything else that could use the space?

Lokks like nothing except ->red_left_pad qualifies for uint8_t.
