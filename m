Date: Tue, 15 May 2001 17:16:58 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105160016.f4G0GwY65956@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva> <3B00CECF.9A3DEEFA@mindspring.com> <200105151724.f4FHOYt54576@earth.backplane.com> <200105160005.f4G05fe26435@maila.telia.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:Are the heuristics persistent? 
:Or will the first use after  boot use the rough prediction? 
:For how long time will the heuristic stick? Suppose it is suddenly used in
:a slightly different way. Like two sequential readers instead of one...
:
:/RogerL
:Roger Larsson
:Skelleftea
:Sweden

    It's based on the VM page cache, so its adaptive over time.  I wouldn't
    call it persistent, it is nothing more then a simple heuristic that
    'normally' throws a page away but 'sometimes' caches it.  In otherwords,
    you lose some performance on the frontend in order to gain some later
    on.  If you loop through a file enough times, most of the file
    winds up getting cached.  It's still experimental so it is only
    lightly tied into the system.  It seems to work, though, so at some
    point in the future I'll probably try to put some significant prediction
    in.  But as I said, it's a very difficult thing to predict.  You can't
    just put your foot down and say 'I'll cache X amount of file Y'.  That
    doesn't work at all.

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
