Date: Mon, 25 Sep 2000 00:13:42 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000925001342.I5571@athlon.random>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000924224303.C2615@redhat.com>; from sct@redhat.com on Sun, Sep 24, 2000 at 10:43:03PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 10:43:03PM +0100, Stephen C. Tweedie wrote:
> any form of serialisation on the quota file).  This feels like rather
> a lot of new and interesting deadlocks to be introducing so late in
> 2.4.  :-)

Agreed.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
