Date: Sun, 6 Jul 2003 02:28:57 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: 2.5.74-mm1
Message-ID: <20030706012857.GA29544@mail.jlokier.co.uk>
References: <20030703023714.55d13934.akpm@osdl.org> <200307052309.12680.phillips@arcor.de> <20030705214413.GA28824@mail.jlokier.co.uk> <200307060010.26002.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200307060010.26002.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips wrote:
> What are you going to do if you have one 
> application you want to take priority, re-nice the other 50?

Is that effective?  It might be just the trick.

> > Something I've often thought would fix this is to allow normal users
> > to set negative priority which is limited to using X% of the CPU -
> > i.e. those tasks would have their priority raised if they spent more
> > than a small proportion of their time using the CPU.
> 
> That's essentially SCHED_RR.  As I mentioned above, it's not clear
> to me why SCHED_RR requires superuser privilege, since the amount of
> CPU you can burn that way is bounded.  Well, the total of all
> SCHED_RR processes would need to be bounded as well, which is
> straightforward.

Your last point is most important.  At the moment, a SCHED_RR process
with a bug will basically lock up the machine, which is totally
inappropriate for a user app.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
