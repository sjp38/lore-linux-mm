From: Daniel Phillips <phillips@arcor.de>
Subject: Re: 2.5.74-mm1
Date: Sun, 6 Jul 2003 04:14:34 +0200
References: <20030703023714.55d13934.akpm@osdl.org> <200307060010.26002.phillips@arcor.de> <20030706012857.GA29544@mail.jlokier.co.uk>
In-Reply-To: <20030706012857.GA29544@mail.jlokier.co.uk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200307060414.34827.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 06 July 2003 03:28, Jamie Lokier wrote:
> Daniel Phillips wrote:
> > What are you going to do if you have one
> > application you want to take priority, re-nice the other 50?
>
> Is that effective?  It might be just the trick.

Point.

> > > Something I've often thought would fix this is to allow normal users
> > > to set negative priority which is limited to using X% of the CPU -
> > > i.e. those tasks would have their priority raised if they spent more
> > > than a small proportion of their time using the CPU.
> >
> > That's essentially SCHED_RR.  As I mentioned above, it's not clear
> > to me why SCHED_RR requires superuser privilege, since the amount of
> > CPU you can burn that way is bounded.  Well, the total of all
> > SCHED_RR processes would need to be bounded as well, which is
> > straightforward.
>
> Your last point is most important.  At the moment, a SCHED_RR process
> with a bug will basically lock up the machine, which is totally
> inappropriate for a user app.

How does the lockup come about?  As defined, a single SCHED_RR process could 
lock up only its own slice of CPU, as far as I can see.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
