Date: Fri, 7 Jul 2000 09:38:23 -0500 (CDT)
From: Oliver Xymoron <oxymoron@waste.org>
Subject: Re: new latency report
In-Reply-To: <39654CCC.9DE5000E@uow.edu.au>
Message-ID: <Pine.LNX.4.10.10007070934580.1903-100000@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Roger Larsson <roger.larsson@norran.net>, "linux-kernel@vger.rutgers.edu" <linux-kernel@vger.rutgers.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-audio-dev@ginette.musique.umontreal.ca" <linux-audio-dev@ginette.musique.umontreal.ca>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Jul 2000, Andrew Morton wrote:

> Try adding the attached patch to your existing tree.  It fixes a lot
> of stuff.  sys_close() and sys_exit() still need attention.

Consider making a macro UGLYSCHEDULINGPOINT for these additions so that we
can find these easily and maybe easily switch between normal and
lowlatency for benchmarking. The 'UGLY' is to do dissuade people from
overuse.

--
 "Love the dolphins," she advised him. "Write by W.A.S.T.E.." 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
