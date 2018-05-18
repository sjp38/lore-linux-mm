Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 083DB6B05D8
	for <linux-mm@kvack.org>; Fri, 18 May 2018 12:23:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r9-v6so3071676pgp.12
        for <linux-mm@kvack.org>; Fri, 18 May 2018 09:23:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s3-v6si7775696plq.87.2018.05.18.09.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 09:23:15 -0700 (PDT)
Date: Fri, 18 May 2018 09:23:14 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Message-ID: <20180518162314.GC25227@infradead.org>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <b3970608-95dd-3d4f-140c-3d7cbd12cf8d@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3970608-95dd-3d4f-140c-3d7cbd12cf8d@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Kent Overstreet <kent.overstreet@gmail.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Fri, May 11, 2018 at 03:13:38PM -0600, Jens Axboe wrote:
> Looked over the series, and looks like both good cleanups and optimizations.
> If we can get the mempool patch sorted, I can apply this for 4.18.

FYI, I agree on the actual cleanups and optimization, but we really
shouldn't add new functions or even just exports without the code
using them.  I think it is enough if we can collect ACKs on them, but
there is no point in using them.  Especially as I'd really like to see
the users for some of them first.
