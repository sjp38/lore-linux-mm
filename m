Date: Sat, 19 Mar 2005 20:33:45 +0100
From: Pavel Machek <pavel@suse.cz>
Subject: Re: [PATCH 0/4] sparsemem intro patches
Message-ID: <20050319193345.GE1504@openzaurus.ucw.cz>
References: <1110834883.19340.47.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1110834883.19340.47.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi!

> Three of these are i386-only, but one of them reorganizes the macros
> used to manage the space in page->flags, and will affect all platforms.
> There are analogous patches to the i386 ones for ppc64, ia64, and
> x86_64, but those will be submitted by the normal arch maintainers.
> 
> The combination of the four patches has been test-booted on a variety of
> i386 hardware, and compiled for ppc64, i386, and x86-64 with about 17
> different .configs.  It's also been runtime-tested on ia64 configs (with
> more patches on top).

Could you try swsusp on i386, too?
-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
