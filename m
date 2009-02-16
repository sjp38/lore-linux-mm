Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E91866B00CA
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 15:20:08 -0500 (EST)
Date: Mon, 16 Feb 2009 12:19:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/8] kzfree()
Message-Id: <20090216121925.a34cca6e.akpm@linux-foundation.org>
In-Reply-To: <4999C556.7010605@cs.helsinki.fi>
References: <20090216142926.440561506@cmpxchg.org>
	<20090216115931.12d9b7ed.akpm@linux-foundation.org>
	<4999C556.7010605@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2009 21:58:14 +0200 Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Hi Andrew,
> 
> Andrew Morton wrote:
> > On Mon, 16 Feb 2009 15:29:26 +0100 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> >> This series introduces kzfree() and converts callsites which do
> >> memset() + kfree() explicitely.
> > 
> > I dunno, this looks like putting lipstick on a pig.
> > 
> > What is the point in zeroing memory just before freeing it?  afacit
> > this is always done as a poor-man's poisoning operation.
> 
> I think they do it as security paranoia to make sure other callers don't 
> accidentally see parts of crypto keys, passwords, and such. So I don't 
> think we can just get rid of the memsets.

Ok, you're right - I thought only a couple were doing that but it looks like
all of them except for perhaps ATM are being non-stupid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
