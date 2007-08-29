Received: from MailerDaemon by bender.weihenstephan.org with local-bsmtp (Exim 4.63)
	(envelope-from <juergen127@kreuzholzen.de>)
	id 1IQPiB-0005MY-6l
	for linux-mm@kvack.org; Wed, 29 Aug 2007 17:44:07 +0200
From: Juergen Beisert <juergen127@kreuzholzen.de>
Subject: Re: speeding up swapoff
Date: Wed, 29 Aug 2007 17:12:35 +0200
References: <1188394172.22156.67.camel@localhost> <20070829073040.1ec35176@laptopd505.fenrus.org> <1188398683.22156.77.camel@localhost>
In-Reply-To: <1188398683.22156.77.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708291712.35967.juergen127@kreuzholzen.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Daniel Drake <ddrake@brontes3d.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 29 August 2007 16:44, Daniel Drake wrote:
> On Wed, 2007-08-29 at 07:30 -0700, Arjan van de Ven wrote:
> > > My experiments show that when there is not much free physical memory,
> > > swapoff moves pages out of swap at a rate of approximately 5mb/sec.
> >
> > sounds like about disk speed (at random-seek IO pattern)
>
> We are only using 'standard' seagate SATA disks, but I would have
> thought much more performance (40+ mb/sec) would be reachable.
>
> > before you go there... is this a "real life" problem? Or just a
> > mostly-artificial corner case? (the answer to that obviously is
> > relevant for the 'should we really care' question)
>
> It's more-or-less a real life problem. We have an interactive
> application which, when triggered by the user, performs rendering tasks
> which must operate in real-time. In attempt to secure performance, we
> want to ensure everything is memory resident and that nothing might be
> swapped out during the process. So, we run swapoff at that time.

Did you play with mlock()?

Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
