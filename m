Date: Wed, 27 Sep 2000 13:55:52 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: the new VMt
In-Reply-To: <20000927181334.A14797@saw.sw.com.sg>
Message-ID: <Pine.LNX.4.21.0009271338220.1006-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrey Savochkin <saw@saw.sw.com.sg>
Cc: Mark Hemment <markhe@veritas.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Sep 2000, Andrey Savochkin wrote:
> 
> It's a waste of resources to reserve memory+swap for the case that every
> running process decides to modify libc code (and, thus, should receive its
> private copy of the pages).   A real waste!

A real waste indeed, but a bad example: libc code is mapped read-only,
so nobody would recommend reserving memory+swap for private mods to it.
Of course, a process might choose to mprotect it writable at some time,
that would be when to refuse if overcommitted.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
