Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: how not to write a search algorithm
Date: Mon, 5 Aug 2002 00:45:23 +0200
References: <3D4CE74A.A827C9BC@zip.com.au> <20020804203804.GD4010@holomorphy.com> <3D4D9802.D1F208F0@zip.com.au>
In-Reply-To: <3D4D9802.D1F208F0@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17bU7n-0000Yb-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 04 August 2002 23:09, Andrew Morton wrote:
> Seems that simply changing the page_add_ramp() interface to require the
> caller to pass in one (err, two) pte_chains would suffice.  The tricky
> one is copy_page_range(), which is probably where -ac panics.

Hmm, seems to me my recent patch did exactly that.  Somebody called
it 'ugly' ;-)

I did intend to move the initialization of that little pool outside
copy_page_range, and never free the remainder.

Why two pte_chains, by the way?

> I suppose we could hang the pool of pte_chains off task_struct
> and have a little "precharge the pte_chains" function.  Gack.

It's not that bad.  It's much nicer than hanging onto the rmap lock
while kmem_cache_alloc does its thing.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
