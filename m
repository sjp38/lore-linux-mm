Date: Mon, 25 Sep 2000 18:45:34 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: refill_inactive()
Message-ID: <20000925184534.M2615@redhat.com>
References: <Pine.LNX.4.21.0009251306430.14614-100000@duckman.distro.conectiva> <Pine.LNX.4.10.10009250914100.1666-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10009250914100.1666-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Sep 25, 2000 at 09:17:54AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 09:17:54AM -0700, Linus Torvalds wrote:
> 
> On Mon, 25 Sep 2000, Rik van Riel wrote:
> > 
> > Hmmm, doesn't GFP_BUFFER simply imply that we cannot
> > allocate new buffer heads to do IO with??
> 
> No.
> 
> New buffer heads would be ok - recursion is fine in theory, as long as it
> is bounded, and we might bound it some other way (I don't think we
> _should_ do recursion here due to the stack limit, but at least it's not
> a fundamental problem).

Right, but we still need to be careful --- we _were_ getting stack
overflows occassionally before the GFP_BUFFER semantics were set up to
prevent that recursion.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
