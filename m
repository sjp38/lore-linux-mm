Message-Id: <200105160005.f4G05fe26435@maila.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: on load control / process swapping
Date: Wed, 16 May 2001 01:55:13 +0200
References: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva> <3B00CECF.9A3DEEFA@mindspring.com> <200105151724.f4FHOYt54576@earth.backplane.com>
In-Reply-To: <200105151724.f4FHOYt54576@earth.backplane.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Dillon <dillon@earth.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

On Tuesday 15 May 2001 19:24, Matt Dillon wrote:
>     I implemented a special page-recycling algorithm in 4.1/4.2 (which is
>     still there in 4.3).  Basically it tries predict when it is possible to
>     throw away pages 'behind' a sequentially accessed file, so as not to
>     allow that file to blow away your cache.  E.G. if you have 128M of ram
>     and you are sequentially accessing a 200MB file, obviously there is
>     not much point in trying to cache the data as you read it.
>
>     But being able to predict something like this is extremely difficult.
>     In fact, nearly impossible.  And without being able to make the
>     prediction accurately you simply cannot determine how much data you
>     should try to cache before you begin recycling it.  I wound up having
>     to change the algorithm to act more like a heuristic -- it does a rough
>     prediction but doesn't hold the system to it, then allows the page
>     priority mechanism to refine the prediction.  But it can take several
>     passes (or non-passes) on the file before the page recycling
> stabilizes.
>

Are the heuristics persistent? 
Or will the first use after  boot use the rough prediction? 
For how long time will the heuristic stick? Suppose it is suddenly used in
a slightly different way. Like two sequential readers instead of one...

/RogerL

-- 
Roger Larsson
Skelleftea
Sweden

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
