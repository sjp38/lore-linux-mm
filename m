Date: Tue, 10 Oct 2000 11:46:23 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010114623.C12032@pcep-jamie.cern.ch>
References: <200010092207.PAA08714@pachyderm.pa.dec.com> <200010092313.e99NDQX173855@saturn.cs.uml.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200010092313.e99NDQX173855@saturn.cs.uml.edu>; from acahalan@cs.uml.edu on Mon, Oct 09, 2000 at 07:13:25PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Albert D. Cahalan" <acahalan@cs.uml.edu>
Cc: Jim Gettys <jg@pa.dec.com>, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Albert D. Cahalan wrote:
> X, and any other big friendly processes, could participate in
> memory balancing operations. X could be made to clean out a
> font cache when the kernel signals that memory is low. When
> the situation becomes serious, X could just mmap /dev/zero over
> top of the background image.

Haven't we already had this discussion?  Quite a lot of programs have
cached data (X fonts, Netscape (lots!)), GC-able data (Emacs, Java
etc.), data that can simply be discarded (X window backing stores), or
data that can be written to disk on demand (Netscape again).

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
