Date: Mon, 20 Aug 2001 20:42:08 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH][RFC] using a memory_clock_interval
In-Reply-To: <200108210022.f7L0Mf320610@mailg.telia.com>
Message-ID: <Pine.LNX.4.21.0108202039120.538-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 21 Aug 2001, Roger Larsson wrote:

> It runs, lets ship it...
> 
> First version of a patch that tries to USE a memory_clock to determine
> when to run kswapd...
> 
> Limits needs tuning... but it runs with almost identical performace as the
> original.
> Note: that the rubberband is only for debug use...
> 
> I will update it for latest kernel... but it might be a week away...

Roger, 

Why are you using memory_clock_interval (plus pages_high, of course) as
the global inactive target ?

That makes the inactive target not dynamic anymore. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
