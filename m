Date: Tue, 29 Oct 2002 15:28:00 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.44-mm6
In-Reply-To: <Pine.LNX.3.96.1021029065944.6113B-100000@gatekeeper.tmr.com>
Message-ID: <Pine.LNX.4.44L.0210291526560.1697-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Oct 2002, Bill Davidsen wrote:
> On Mon, 28 Oct 2002, Andrew Morton wrote:
> > Rik van Riel wrote:
> > > Just let me know if you're interested in my load control mechanism
> > > and I'll send it to you.
> > It would also be interesting to know if we really care?
>
> I think there is a need for keeping an overloaded machine in some way
> usable, not because anyone is really running it that way, but because
> the sysadmin needs a way to determine why a correctly sized machine is
> suddenly seeing a high load.

Indeed, it's a stability thing, not a performance thing.

It's Not Good(tm) to have a system completely crap out because
of a load spike. Instead it should survive the load spike and
go on with life.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".
http://www.surriel.com/		http://distro.conectiva.com/
Current spamtrap:  <a href=mailto:"october@surriel.com">october@surriel.com</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
