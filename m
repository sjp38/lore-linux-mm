Date: Thu, 13 Jul 2000 11:34:38 +0100 (BST)
From: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Subject: Re: [PATCH] page ageing with lists
In-Reply-To: <396D1817.108394F5@norran.net>
Message-ID: <Pine.LNX.4.21.0007131129590.4769-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jul 2000, Roger Larsson wrote:

> Hi,
> 
> This is a patch with page ageing for 2.4.0-test4-pre1.
> 
> Performance, unoptimized filesystem:
> * streamed write is as good as 2.2.14
> * streamed copy is 3/4 of 2.2.14
> * streamed read is close to 2.2.14

Has anyone tested 2.4.0-test4-pre4 without any patches?

And shouldn't (in particular) streamed write be faster than 2.2 on account
of the unified buffer cache in 2.3?

Cheers
Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
