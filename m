From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14329.390.453805.801086@dukat.scot.redhat.com>
Date: Mon, 4 Oct 1999 20:35:34 +0100 (BST)
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910041428030.8295-100000@imperial.edgeglobal.com>
References: <14328.53659.36975.874284@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9910041428030.8295-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 4 Oct 1999 14:29:14 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Okay. But none of this prevents a rogue app from hosing your system. Such
> a process doesn't have to bother with locks or semaphores. 

And we talked about this before.  You _can_ make such a guarantee, but
it is hideously expensive especially on SMP.  You either protect the
memory or the CPU against access by the other app, and that requires
either scheduler or VM interrupts between CPUs.

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
