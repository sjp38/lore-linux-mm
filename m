Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: inactive_dirty list
Date: Sun, 8 Sep 2002 23:21:43 +0200
References: <3D7930D6.F658E5B9@zip.com.au> <Pine.LNX.4.44L.0209061958090.1857-100000@imladris.surriel.com> <3D793B9E.AAAC36CA@zip.com.au>
In-Reply-To: <3D793B9E.AAAC36CA@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17oGD3-0006li-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 07 September 2002 01:34, Andrew Morton wrote:
> You're proposing that we get that IO underway sooner if there
> is page reclaim pressure, and that one way to do that is to
> write one page for every reclaimed one.  Guess that makes
> sense as much as anything else ;)

Not really.  The correct formula will incorporate the allocation rate and the 
inactive dirty/clean balance.  The reclaim rate is not relevant, it is a 
time-delayed consequence of the above.  Relying on it in a control loop is 
simply asking for oscillation.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
