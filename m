Date: Mon, 30 Apr 2001 15:00:36 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: Hopefully a simple question on /proc/pid/mem
In-Reply-To: <20010430195007.F26638@redhat.com>
Message-ID: <Pine.GSO.4.21.0104301457010.5737-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 30 Apr 2001, Stephen C. Tweedie wrote:

> > Now I've tried using ptrace(), mmap() & lseek/read all with no success.  
> > The closest I've been able to get is to use ptrace() to do an attach to 
> > the target process, but couldn't read much of anything from it.
> 
> ptrace is what other debuggers use.  It really ought to work.

I wonder what's wrong with reading from /proc/<pid>/mem, though - it's
using the same code as ptrace.

Al, considering adding /proc/<pid>/{regs,fpregs,ctl} and moving ptrace()
entirely to userland...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
