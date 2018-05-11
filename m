Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 64AF06B06D1
	for <linux-mm@kvack.org>; Fri, 11 May 2018 17:11:49 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o23-v6so3881758pll.12
        for <linux-mm@kvack.org>; Fri, 11 May 2018 14:11:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f82-v6sor1503581pfd.122.2018.05.11.14.11.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 14:11:48 -0700 (PDT)
Subject: Re: [PATCH 01/10] mempool: Add mempool_init()/mempool_exit()
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <20180509013358.16399-2-kent.overstreet@gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <f6b03dbb-a9d0-2b5b-c21a-e92572bc343a@kernel.dk>
Date: Fri, 11 May 2018 15:11:45 -0600
MIME-Version: 1.0
In-Reply-To: <20180509013358.16399-2-kent.overstreet@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kent Overstreet <kent.overstreet@gmail.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 5/8/18 7:33 PM, Kent Overstreet wrote:
> Allows mempools to be embedded in other structs, getting rid of a
> pointer indirection from allocation fastpaths.
> 
> mempool_exit() is safe to call on an uninitialized but zeroed mempool.

Looks fine to me. I'd like to carry it through the block branch, as some
of the following cleanups depend on it. Kent, can you post a v2 with
the destroy -> exit typo fixed up?

But would be nice to have someone sign off on it...

-- 
Jens Axboe
