Date: Mon, 30 Apr 2001 19:50:07 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Hopefully a simple question on /proc/pid/mem
Message-ID: <20010430195007.F26638@redhat.com>
References: <3AEDAC29.40309@link.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3AEDAC29.40309@link.com>; from rfweber@link.com on Mon, Apr 30, 2001 at 02:17:13PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard F Weber <rfweber@link.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 30, 2001 at 02:17:13PM -0400, Richard F Weber wrote:
> Hopefully this is a simple question.  I'm trying to work on an external 
> debugger that can bind to an external process, and open up memory 
> locations on the heap to allow reading of data.
> 
> Now I've tried using ptrace(), mmap() & lseek/read all with no success.  
> The closest I've been able to get is to use ptrace() to do an attach to 
> the target process, but couldn't read much of anything from it.

ptrace is what other debuggers use.  It really ought to work.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
