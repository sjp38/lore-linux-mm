Date: Thu, 13 Apr 2000 22:00:03 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: A question about pages in stacks
Message-ID: <20000413220003.E13446@redhat.com>
References: <200004131958.VAA00863@agnes.bagneux.maison>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004131958.VAA00863@agnes.bagneux.maison>; from jfm2@club-internet.fr on Thu, Apr 13, 2000 at 09:58:44PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: JF Martinez <jfm2@club-internet.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Apr 13, 2000 at 09:58:44PM +0200, JF Martinez wrote:
> Let's imagine that when looking for a pege the kerneml a page who has
> been part of a stack frame but since then the stack has shrunk so it
> is no longer in it.  Will the kernel save it to disk or will it
> recognize it as a page who despite what the dirty bit could say  is
> in fact free and does not need to be saved?

The kernel will never throw away unused stack pages unless the
process explicitly unmaps them.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
