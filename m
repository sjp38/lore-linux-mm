Date: Thu, 28 Sep 2000 17:23:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000928172351.O17518@athlon.random>
References: <20000928165427.K17518@athlon.random> <Pine.LNX.4.21.0009281704430.9445-100000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009281704430.9445-100000@elte.hu>; from mingo@elte.hu on Thu, Sep 28, 2000 at 05:13:59PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Rohland <cr@sap.com>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 28, 2000 at 05:13:59PM +0200, Ingo Molnar wrote:
> Can anyone see any problems with the concept of this approach? This can be

It works only on top of a filesystem while all the checkpointing clever stuff
is done internally by the DB (infact it _needs_ O_SYNC when it works on the
fs).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
