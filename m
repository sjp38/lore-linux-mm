Date: Tue, 2 Nov 2004 09:55:58 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
In-Reply-To: <4186E41E.5080909@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411020955470.28110@server.graphe.net>
References: <4181EF2D.5000407@yahoo.com.au> <20041029074607.GA12934@holomorphy.com>
 <Pine.LNX.4.58.0411011612060.8399@server.graphe.net> <20041102005439.GQ2583@holomorphy.com>
 <4186E41E.5080909@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2004, Nick Piggin wrote:

> But aside from all that, Christoph's patch _doesn't_ move the
> locking out of tlb_gather operations IIRC.

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
