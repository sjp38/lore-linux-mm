Date: Tue, 10 Oct 2000 11:54:51 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001010115451.D12032@pcep-jamie.cern.ch>
References: <39E22E80.75819894@kalifornia.com> <200010100422.e9A4Mg722840@webber.adilger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200010100422.e9A4Mg722840@webber.adilger.net>; from adilger@turbolinux.com on Mon, Oct 09, 2000 at 10:22:42PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Dilger <adilger@turbolinux.com>
Cc: david+validemail@kalifornia.com, Rik van Riel <riel@conectiva.com.br>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, jg@pa.dec.com, alan@lxorguk.ukuu.org.uk, acahalan@cs.uml.edu, Gerrit.Huizenga@us.ibm.com
List-ID: <linux-mm.kvack.org>

Andreas Dilger wrote:
> Having a SIGDANGER handler is good for 2 reasons:
> 1) Lets processes know when memory is short so they can free needless cache.
> 2) Mark process with a SIGDANGER handler as "more important" than those
>    without.  Most people won't care about this, but init, and X, and
>    long-running simulations might.

For point 1, it would be much nicer to have user processes participate
in memory balancing _before_ getting anywhere near an OOM state.

A nice way is to send SIGDANGER with siginfo saying how much memory the
kernel wants back (or how fast).  Applications that don't know to use
that info, but do have a SIGDANGER handler, will still react just rather
more severely.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
