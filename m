Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F09C6B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 15:11:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d5-v6so16215855qtg.17
        for <linux-mm@kvack.org>; Mon, 14 May 2018 12:11:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a40-v6sor8048401qvd.7.2018.05.14.12.11.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 May 2018 12:11:14 -0700 (PDT)
Date: Mon, 14 May 2018 15:11:10 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 01/10] mempool: Add mempool_init()/mempool_exit()
Message-ID: <20180514191110.GB8869@kmo-pixel>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <20180509013358.16399-2-kent.overstreet@gmail.com>
 <f6b03dbb-a9d0-2b5b-c21a-e92572bc343a@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6b03dbb-a9d0-2b5b-c21a-e92572bc343a@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, May 11, 2018 at 03:11:45PM -0600, Jens Axboe wrote:
> On 5/8/18 7:33 PM, Kent Overstreet wrote:
> > Allows mempools to be embedded in other structs, getting rid of a
> > pointer indirection from allocation fastpaths.
> > 
> > mempool_exit() is safe to call on an uninitialized but zeroed mempool.
> 
> Looks fine to me. I'd like to carry it through the block branch, as some
> of the following cleanups depend on it. Kent, can you post a v2 with
> the destroy -> exit typo fixed up?
> 
> But would be nice to have someone sign off on it...

Done - it's now up in my git repo:
http://evilpiepirate.org/git/bcachefs.git bcachefs-block
