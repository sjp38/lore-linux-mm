Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH] ageable slab callbacks
Date: Sun, 15 Sep 2002 19:54:25 -0400
References: <200209151436.20171.tomlins@cam.org> <3D851B5A.49F4296B@digeo.com>
In-Reply-To: <3D851B5A.49F4296B@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200209151954.25689.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On September 15, 2002 07:44 pm, Andrew Morton wrote:
> Hi, Ed.

Geez, I did miss alot didn't I?  Thanks for the review, I will
eyeball the next one much more carefully.

> Ed Tomlinson wrote:
> > Hi,
> >
> > This lets the vm use callbacks to shrink ageable caches.   With this we
> > avoid having to change vmscan if an ageable cache family is added.  It
> > also batches calls to the prune methods (SHRINK_BATCH).
>
> I do believe it would be better to move the batching logic into
> slab.c and not make the individual cache implementations have
> to know about it.  Just put the accumulators into cachep-> and
> only call the shrinker when the counter reaches the threshold

Yes it would be better.  Problem is how to find the number of entries in
the cache we want to prune.  We could ask the shrink callback return
this when passed a zero in ratio - I do not like dual purpose functions
that much though...

Thanks,

Ed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
