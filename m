Date: Mon, 25 Sep 2000 18:29:06 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925182906.A27677@athlon.random>
References: <Pine.GSO.4.21.0009251157390.16980-100000@weyl.math.psu.edu> <Pine.LNX.4.21.0009251819380.9122-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009251819380.9122-100000@elte.hu>; from mingo@elte.hu on Mon, Sep 25, 2000 at 06:20:40PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alexander Viro <viro@math.psu.edu>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 06:20:40PM +0200, Ingo Molnar wrote:
> i only suggested this as a debugging helper, instead of the suggested

I don't think removing the superlock from all fs is good thing at this stage (I
agree with SCT doing it only for ext2 [that's what we mostly care about] would
be possible). Who cares if UFS grabs the super lock or not?

grep lock_super fs/ext2/*.c is enough and we don't need debugging in the
scheduler for that.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
