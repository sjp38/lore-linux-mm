Message-ID: <39E22E80.75819894@kalifornia.com>
Date: Mon, 09 Oct 2000 13:45:53 -0700
From: David Ford <david@kalifornia.com>
Reply-To: david+validemail@kalifornia.com
MIME-Version: 1.0
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
References: <Pine.LNX.4.21.0010091733240.1562-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

> > How about SIGTERM a bit before SIGKILL then re-evaluate the OOM
> > N usecs later?
>
> And run the risk of having to kill /another/ process as well ?
>
> I really don't know if that would be a wise thing to do
> (but feel free to do some tests to see if your idea would
> work ... I'd love to hear some test results with your idea).

I was thinking (dangerous) about an urgent v.s. critical OOM.  urgent could
trigger a SIGTERM which would give advance notice to the offending process.
I don't think we have a signal method of notifying processes when resources
are critically low, feel free to correct me.

Is there a signal that -might- be used for this?

-d

--
      "There is a natural aristocracy among men. The grounds of this are
      virtue and talents", Thomas Jefferson [1742-1826], 3rd US President



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
