Date: Mon, 27 Jun 2005 09:44:15 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: VFS scalability
Message-ID: <20050627074414.GB14251@wotan.suse.de>
References: <42BF9CD1.2030102@yahoo.com.au> <42BFA014.9090604@yahoo.com.au> <p733br4w9uw.fsf@verdi.suse.de> <42BFABD7.5000006@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42BFABD7.5000006@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 27, 2005 at 05:33:43PM +1000, Nick Piggin wrote:
> >Maybe adding a prefetch for it at the beginning of sys_read() 
> >might help, but then with 64CPUs writing to parts of the inode
> >it will always thrash no matter how many prefetches.
> >
> 
> True. I'm just not sure what is causing the bouncing - I guess
> ->f_count due to get_file()?

That's in the file, not in the inode. It must be some inode field.
I don't know which one.

There is probably some oprofile/perfmon event that could tell
you which function dirties the cacheline.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
