Date: Mon, 11 Mar 2002 12:08:18 +0000
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [bkpatch] do_mmap cleanup
Message-ID: <20020311120818.A38@toy.ucw.cz>
References: <20020308185350.E12425@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20020308185350.E12425@redhat.com>; from bcrl@redhat.com on Fri, Mar 08, 2002 at 06:53:50PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> Below is a vm cleanup that can be pulled from bk://bcrlbits.bk.net/vm-2.5 .
> The bulk of the patch is moving the down/up_write on mmap_sem into do_mmap 
> and removing that from all the callers.  The patch also includes a fix for 
> do_mmap which caused mapping of the last page in the address space to fail.

Was not that a workaround for CPU bugs?
									Pavel

-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
