Date: Mon, 30 Apr 2001 15:44:32 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: Hopefully a simple question on /proc/pid/mem
In-Reply-To: <Pine.LNX.3.96.1010430152401.30664E-100000@kanga.kvack.org>
Message-ID: <Pine.GSO.4.21.0104301532130.5737-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 30 Apr 2001, Benjamin C.R. LaHaise wrote:

> On Mon, 30 Apr 2001, Alexander Viro wrote:
> 
> > ITYM "disabling _write_ on /proc/*/mem". Read is OK. Anyway, current
> > mem_write() uses the same code as PTRACE_POKEDATA, so if the latter works,
> > the former also should be OK.
> 
> Actually, even read on /proc/*/mem caused problems in 2.0: the elevated
> usage could would prevent memory from being reclaimed by the swapper
> properly.  Things are so much better now it's not even funny.

ISTR removing some rather nasty code during the procfs rewrite. From
mem_read() and mem_write() - basically, made them wrappers around
access_process_vm().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
