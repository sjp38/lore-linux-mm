Date: Fri, 6 Apr 2001 22:22:56 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] swap_state.c thinko
Message-ID: <20010406222256.C935@athlon.random>
References: <Pine.LNX.4.21.0104061932300.1374-100000@localhost.localdomain> <Pine.LNX.4.31.0104061245320.25931-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.31.0104061245320.25931-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Fri, Apr 06, 2001 at 12:52:26PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ben LaHaise <bcrl@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Richard Jerrrell <jerrell@missioncriticallinux.com>, Stephen Tweedie <sct@redhat.com>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 06, 2001 at 12:52:26PM -0700, Linus Torvalds wrote:
> vm_enough_memory() is a heuristic, nothing more. We want it to reflect
> _some_ view of reality, but the Linux VM is _fundamentally_ based on the
> notion of over-commit, and that won't change. vm_enough_memory() is only
> meant to give a first-order appearance of not overcommitting wildly. It
> has never been anything more than that.

200% agreed.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
