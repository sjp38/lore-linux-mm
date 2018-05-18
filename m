Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6DA06B05EC
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:21:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x21-v6so4963997pfn.23
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:21:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e184-v6si6297847pgc.475.2018.05.18.09.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:21:28 -0700 (PDT)
Date: Fri, 18 May 2018 09:21:28 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 02/10] block: Convert bio_set to mempool_init()
Message-ID: <20180518162128.GB25227@infradead.org>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <20180509013358.16399-3-kent.overstreet@gmail.com>
 <20180518162028.GA25227@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518162028.GA25227@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>

On Fri, May 18, 2018 at 09:20:28AM -0700, Christoph Hellwig wrote:
> On Tue, May 08, 2018 at 09:33:50PM -0400, Kent Overstreet wrote:
> > Minor performance improvement by getting rid of pointer indirections
> > from allocation/freeing fastpaths.
> 
> Can you please also send a long conversion for the remaining
> few bioset_create users?  It would be rather silly to keep two
> almost the same interfaces around for just about two hand full
> of users.

This comment was ment in reply to the next patch, sorry.
