Date: Sun, 19 Aug 2001 01:27:13 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819012713.N1719@athlon.random>
References: <Pine.LNX.4.33.0108161651070.24312-100000@touchme.toronto.redhat.com> <Pine.LNX.4.33.0108181420050.11338-100000@toomuch.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0108181420050.11338-100000@toomuch.toronto.redhat.com>; from bcrl@redhat.com on Sat, Aug 18, 2001 at 02:22:12PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 18, 2001 at 02:22:12PM -0400, Ben LaHaise wrote:
> It appears that whitespace was mangled.  Here's a resend of the patch,
> uuencoded.

This below patch besides rewriting the vma lookup engine also covers the
cases addressed by your patch:

	ftp://ftp.kernel.org/pub/linux/kernel/people/andrea/patches/v2.4/2.4.9/mmap-rb-4

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
