Date: Sat, 5 Jul 2003 22:44:13 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: 2.5.74-mm1
Message-ID: <20030705214413.GA28824@mail.jlokier.co.uk>
References: <20030703023714.55d13934.akpm@osdl.org> <200307051728.12891.phillips@arcor.de> <20030705121416.62afd279.akpm@osdl.org> <200307052309.12680.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200307052309.12680.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> Unfortunately, negative priority requires root privilege, at least
> on Debian.
>
> That's dumb.  By default, the root privilege requirement should kick
> in at something like -5 or -10, so ordinary users can set priorities
> higher than the default, as well as lower.  For the millions of
> desktop users out there, sound ought to work by default, not be
> broken by default.

The security problem, on a multi-user box, is that negative priority
apps can easily take all of the CPU and effectively lock up the box.

Something I've often thought would fix this is to allow normal users
to set negative priority which is limited to using X% of the CPU -
i.e. those tasks would have their priority raised if they spent more
than a small proportion of their time using the CPU.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
