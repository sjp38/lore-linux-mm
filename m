Message-ID: <39B2C4EF.187E1E5E@zk3.dec.com>
Date: Sun, 03 Sep 2000 17:38:55 -0400
From: Peter Rival <frival@zk3.dec.com>
MIME-Version: 1.0
Subject: Re: Rik van Riel's VM patch
References: <200009030010.RAA01038@gnuppy.monkey.org> <39B1B3F1.B228FABA@timpanogas.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jeff V. Merkey" <jmerkey@timpanogas.com>
Cc: Bill Huey <billh@gnuppy.monkey.org>, John Levon <moz@compsoc.man.ac.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


"Jeff V. Merkey" wrote:

> Someone tell Rik to get his hands on a copy of AIMS-7 and start
> benchmarking his VM so when the SCO Unix numbers hit the street, we've
> got a rebuttal and fix dates to tell folks.
>

That's going to be tough - AIM as a company is out of business (just go to
www.aim.com and be surprised ;).  And not to get off-topic, but there are bigger
problems with AIM7 tests than the VM (like the fact that they have hundreds of
runnable processes at any given time which our global run queue doesn't handle
well).  Really - pick something like SPECWeb99...oh, wait - we already destroy
the competition there... :)

 - Pete (still looking for a complete systemic test that's like AIM only more
realistic)

>
> :-)
>
> Jeff
>
> Bill Huey wrote:
> >
> > John,
> >
> > > Hi, this is just a short no-statistics testimony that Rik's VM patch
> > > to test8-pre1 seems much improved over test7. I have a UP P200 with 40Mb,
> > > and previously running KDE2 + mozilla was totally unusable.
> >
> > > With the patch, things run much more smoothly. Interactive feel seems
> > > better, and I don't have "swapping holidays" any more.
> >
> > > Heavily stressing it by g++ is better as well...
> > >
> > > just a data point,
> > > john
> >
> > Yes, it kicks butt and it finally (just about) removes the final
> > Linux kernel showstopper for recent kernels. ;-)
> >
> > I did a GNOME + KDE2 + c++ compile since I've been doing port work
> > and I have similar experiences.
> >
> > bill
> >
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > Please read the FAQ at http://www.tux.org/lkml/
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> Please read the FAQ at http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
