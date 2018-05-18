Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C84406B064D
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:36:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w201-v6so2010492qkb.16
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:36:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t126-v6sor6346553qkc.26.2018.05.18.10.36.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 10:36:25 -0700 (PDT)
Date: Fri, 18 May 2018 13:36:21 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 02/10] block: Convert bio_set to mempool_init()
Message-ID: <20180518173621.GA31737@kmo-pixel>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <20180509013358.16399-3-kent.overstreet@gmail.com>
 <20180518162028.GA25227@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180518162028.GA25227@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
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

Yeah, I can do that
