Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 846B96B0003
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 01:57:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q15so17733975pff.15
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 22:57:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c24-v6si18944553plo.113.2018.04.25.22.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 22:57:30 -0700 (PDT)
Date: Wed, 25 Apr 2018 22:57:27 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] iomap: add a swapfile activation function
Message-ID: <20180426055727.GA24887@infradead.org>
References: <20180418025023.GM24738@magnolia>
 <20180424173539.GB25233@infradead.org>
 <20180425234622.GC1661@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180425234622.GC1661@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Aleksei Besogonov <cyberax@amazon.com>

On Wed, Apr 25, 2018 at 04:46:22PM -0700, Darrick J. Wong wrote:
> (I mean, we /could/ just treat the swapfile as an unbreakable rdma/dax
> style lease, but ugh...)

That is what I think it should be long term, instead of a strange
parallel I/O path.

But in the mean time we have a real problem with supporting swap files,
so we should merge the approaches from you and Aleksei and get something
in ASAP.
