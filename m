Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
Date: Wed, 19 Jun 2002 19:00:57 +0200
References: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
In-Reply-To: <Pine.LNX.4.44.0206181340380.3031-100000@loke.as.arizona.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17KipF-0000up-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 19 June 2002 13:18, Craig Kulesa wrote:
> Where:  http://loke.as.arizona.edu/~ckulesa/kernel/rmap-vm/
>
> This patch implements Rik van Riel's patches for a reverse mapping VM 
> atop the 2.5.23 kernel infrastructure...
>
> ...Hope this is of use to someone!  It's certainly been a fun and 
> instructive exercise for me so far.  ;)

It's intensely useful.  It changes the whole character of the VM discussion 
at the upcoming kernel summit from 'should we port rmap to mainline?' to 'how 
well does it work' and 'what problems need fixing'.  Much more useful.

Your timing is impeccable.  You really need to cc Linus on this work, 
particularly your minimal, lru version.

-- 
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
