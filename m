Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5149B6B00C8
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 15:02:30 -0500 (EST)
Message-ID: <4999C556.7010605@cs.helsinki.fi>
Date: Mon, 16 Feb 2009 21:58:14 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 0/8] kzfree()
References: <20090216142926.440561506@cmpxchg.org> <20090216115931.12d9b7ed.akpm@linux-foundation.org>
In-Reply-To: <20090216115931.12d9b7ed.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Andrew Morton wrote:
> On Mon, 16 Feb 2009 15:29:26 +0100 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
>> This series introduces kzfree() and converts callsites which do
>> memset() + kfree() explicitely.
> 
> I dunno, this looks like putting lipstick on a pig.
> 
> What is the point in zeroing memory just before freeing it?  afacit
> this is always done as a poor-man's poisoning operation.

I think they do it as security paranoia to make sure other callers don't 
accidentally see parts of crypto keys, passwords, and such. So I don't 
think we can just get rid of the memsets.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
