Message-Id: <200108212108.f7LL8Za08285@maila.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [PATCH][RFC] using a memory_clock_interval
Date: Tue, 21 Aug 2001 23:04:13 +0200
References: <Pine.LNX.4.21.0108202039120.538-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0108202039120.538-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesdayen den 21 August 2001 01:42, Marcelo Tosatti wrote:
> On Tue, 21 Aug 2001, Roger Larsson wrote:
> > It runs, lets ship it...
> >
> > First version of a patch that tries to USE a memory_clock to determine
> > when to run kswapd...
> >
> > Limits needs tuning... but it runs with almost identical performace as
> > the original.
> > Note: that the rubberband is only for debug use...
> >
> > I will update it for latest kernel... but it might be a week away...
>
> Roger,
>
> Why are you using memory_clock_interval (plus pages_high, of course) as
> the global inactive target ?
>
> That makes the inactive target not dynamic anymore.

It is still dymanic due the fact that kswapd will be run not depending on a
wall clock, but on problematic allocations done.
(i.e. inactive_target looses its meaning for the VM since it measures
pages/second but second is no more a base for kswapd runs...
both mean - I want to have this amount of reclaimable pages until the next 
kswapd run...)

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
