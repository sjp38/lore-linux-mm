Date: Wed, 15 Aug 2001 18:54:00 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108152343460.972-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0108151853180.26574-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Aug 2001, Hugh Dickins wrote:

> On Wed, 15 Aug 2001, Linus Torvalds wrote:
> > 
> > So something like the appended (UNTESTED!) should be better. How does it
> > work for you?
> 
> Many thanks for your explanation.  You've convinced me that
> create_buffers() has very good reason to make that effort.
> 
> Your patch works fine for me, for getting things moving again.
> I'm not sure if you thought it would stop my "0-order allocation failed"
> messages: no, I still get a batch of those before it settles back to work.

What is the mask of the failing allocations ? 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
