Message-ID: <20000928112516.C16833@saw.sw.com.sg>
Date: Thu, 28 Sep 2000 11:25:16 +0800
From: Andrey Savochkin <saw@saw.sw.com.sg>
Subject: Re: the new VMt
References: <20000927181334.A14797@saw.sw.com.sg> <Pine.LNX.4.21.0009271338220.1006-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009271338220.1006-100000@localhost.localdomain>; from "Hugh Dickins" on Wed, Sep 27, 2000 at 01:55:52PM
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Mark Hemment <markhe@veritas.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, Sep 27, 2000 at 01:55:52PM +0100, Hugh Dickins wrote:
> On Wed, 27 Sep 2000, Andrey Savochkin wrote:
> > 
> > It's a waste of resources to reserve memory+swap for the case that every
> > running process decides to modify libc code (and, thus, should receive its
> > private copy of the pages).   A real waste!
> 
> A real waste indeed, but a bad example: libc code is mapped read-only,
> so nobody would recommend reserving memory+swap for private mods to it.
> Of course, a process might choose to mprotect it writable at some time,
> that would be when to refuse if overcommitted.

Returning error from mprotect() call for private mappings?
It wouldn't be what people expect...

The other example where overcommit makes sense is fork() (not vfork) and
immediate exec in one of the threads.

Best regards
		Andrey
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
