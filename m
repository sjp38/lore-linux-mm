Subject: Re: [RFC][PATCH] IO wait accounting
References: <Pine.LNX.4.44L.0205091607400.7447-100000@duckman.distro.conectiva>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: Sun, 12 May 2002 21:05:03 +0200
In-Reply-To: <Pine.LNX.4.44L.0205091607400.7447-100000@duckman.distro.conectiva> (Rik
 van Riel's message of "Thu, 9 May 2002 16:08:16 -0300 (BRT)")
Message-ID: <87bsbl9ogw.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Bill Davidsen <davidsen@tmr.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:
>
> And should we measure read() waits as well as page faults or
> just page faults ?
>

Definitely both. Somewhere on the web was a nice document explaining
how Solaris measures iowait%, I read it few years ago and it was a
great stuff (quite nice explanation).

I'll try to find it, as it could be helpful.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
