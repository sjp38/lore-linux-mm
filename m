Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 3C8F26B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:14:03 -0400 (EDT)
Date: Mon, 1 Apr 2013 20:14:01 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: system death under oom - 3.7.9
In-Reply-To: <CAKb7UviwOk9asT=WxYgDUzfm3J+tGXobroUycpoTvzOX5kkofQ@mail.gmail.com>
Message-ID: <0000013dc73c284d-29fd15db-416b-40cc-81b6-81abc5bd3c02-000000@email.amazonses.com>
References: <CAKb7UviwOk9asT=WxYgDUzfm3J+tGXobroUycpoTvzOX5kkofQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilia Mirkin <imirkin@alum.mit.edu>
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org, linux-mm@kvack.org

On Wed, 27 Mar 2013, Ilia Mirkin wrote:

> The GPF happens at +160, which is in the argument setup for the
> cmpxchg in slab_alloc_node. I think it's the call to
> get_freepointer(). There was a similar bug report a while back,
> https://lkml.org/lkml/2011/5/23/199, and the recommendation was to run
> with slub debugging. Is that still the case, or is there a simpler
> explanation? I can't reproduce this at will, not sure how many times
> this has happened but definitely not many.

slub debugging will help to track down the cause of the memory corruption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
