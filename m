Date: Thu, 13 Apr 2000 17:27:43 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: A question about pages in stacks
In-Reply-To: <200004131958.VAA00863@agnes.bagneux.maison>
Message-ID: <Pine.LNX.3.96.1000413172501.13371A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: JF Martinez <jfm2@club-internet.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Apr 2000, JF Martinez wrote:

> Let's imagine that when looking for a pege the kerneml a page who has
> been part of a stack frame but since then the stack has shrunk so it
> is no longer in it.  Will the kernel save it to disk or will it
> recognize it as a page who despite what the dirty bit could say  is
> in fact free and does not need to be saved?

It will have to be flushed to swap.  Stack shrinkage must be explicitely
performed, preferably using madvise.  To this end, they could use a hint
from the kernel about the actual size of the stack (see the stack
discussions that have come up over the past week or two). 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
