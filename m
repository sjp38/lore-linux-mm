Date: Tue, 20 Aug 2002 19:41:42 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] rmap 14
Message-ID: <20020820194142.M2645@redhat.com>
References: <9C5FA1BA-B3A6-11D6-A545-000393829FA4@cs.amherst.edu> <Pine.LNX.4.44.0208192128560.23261-100000@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0208192128560.23261-100000@skynet>; from mel@csn.ul.ie on Mon, Aug 19, 2002 at 10:04:19PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel <mel@csn.ul.ie>
Cc: Scott Kaplan <sfkaplan@cs.amherst.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Aug 19, 2002 at 10:04:19PM +0100, Mel wrote:

> > That's exactly the concern that I had.  Large timing result like that are
> > more likely because your code was preempted for something else.  It would
> > probably be good to do *something* about these statistical outliers,
> > because they can affect averages substantially.
> 
> At the moment I'm not calculating averages and I haven't worked out the
> best way to factor in large skews in page reads. For the moment, I'm
> taking the easy option and depending on the tester to be able to ignore
> the bogus data.

You can get that by a bit of stats: keeping track of the sum of each
value you observe plus their squares and cubes gives you the main
stats you probably want to collect:

	mean			(obvious)
	standard deviation 	(measures variation between samples)
	standard error		(shows how accurate your estimation of
				 the mean is)
and	skew/3rd-moment		(shows how one-sided the distribution
				 is)

Distributions with a long tail to one side will have a high skew.  The
main one is standard error, though --- without that you have no idea
how useful your results are.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
