Message-ID: <3972B165.8114E267@norran.net>
Date: Mon, 17 Jul 2000 09:10:29 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [PATCH] test5-1 vm fix
References: <Pine.LNX.4.21.0007161631230.26300-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Mike Galbraith <mikeg@weiden.de>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Sun, 16 Jul 2000, Mike Galbraith wrote:
> > On Sun, 16 Jul 2000, Roger Larsson wrote:
> >
> > > Since I am responsible for messing up some aspects of vm
> > > (when fixing others)
> > > here is a patch that tries to solve the introduced problems.
> 
> > Unfortunately, this didn't improve anything here.
> 
> As was to be expected ...
> 
> Roger, I thought I explained you yesterday why stuff didn't work
> and how it could be fixed? ;)
> 
> (and no, I'm not interested in trying to fix 2.4 VM right now
> since I'll be going to OLS and last time it took only two weeks
> for VM to be fucked up while I was away)
> 

Yes, Now I remember...

We should alway start kswapd after when all zones are found
to be zone_wake_kswapd... (but it will then only run once... but
probably free more pages than we alloc)

Expect a new patch soon... I will do more performance testing this
time...

/RogerL

> cheers,
> 
> Rik
> --
> "What you're running that piece of shit Gnome?!?!"
>        -- Miguel de Icaza, UKUUG 2000
> 
> http://www.conectiva.com/               http://www.surriel.com/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
