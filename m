Date: Mon, 11 Mar 2002 13:39:47 -0700
From: Tom Rini <trini@kernel.crashing.org>
Subject: Re: [bkpatch] do_mmap cleanup
Message-ID: <20020311203947.GA735@opus.bloom.county>
References: <20020308185350.E12425@redhat.com> <20020311120818.A38@toy.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020311120818.A38@toy.ucw.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Benjamin LaHaise <bcrl@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2002 at 12:08:18PM +0000, Pavel Machek wrote:
> Hi!
> 
> > Below is a vm cleanup that can be pulled from bk://bcrlbits.bk.net/vm-2.5 .
> > The bulk of the patch is moving the down/up_write on mmap_sem into do_mmap 
> > and removing that from all the callers.  The patch also includes a fix for 
> > do_mmap which caused mapping of the last page in the address space to fail.
> 
> Was not that a workaround for CPU bugs?

In generic code, I'd hope not.

-- 
Tom Rini (TR1265)
http://gate.crashing.org/~trini/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
