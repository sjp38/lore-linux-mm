Subject: Re: [patch] mm-cleanup-1 (2.4.0)
References: <Pine.LNX.4.21.0101071917250.21675-100000@duckman.distro.conectiva>
Reply-To: zlatko@iskon.hr
From: Zlatko Calusic <zlatko@iskon.hr>
Date: 07 Jan 2001 23:23:38 +0100
In-Reply-To: Rik van Riel's message of "Sun, 7 Jan 2001 19:18:31 -0200 (BRDT)"
Message-ID: <873dev57dh.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 7 Jan 2001, Zlatko Calusic wrote:
> 
> > OK, maybe I was too fast in concluding with that change. I'm
> > still trying to find out why is MM working bad in some
> > circumstances (see my other email to the list).
> > 
> > Anyway, I would than suggest to introduce another /proc entry
> > and call it appropriately: max_async_pages. Because that is what
> > we care about, anyway. I'll send another patch.
> 
> In fact, that's NOT what we care about.
> 
> What we really care about is the number of disk seeks
> the VM subsystem has queued to disk, since it's seek
> time that causes other requests to suffer bad latency.
> 

Yes, but that's not what we have in the code now. I'm just trying to
make it little easier for the end user to tune his system. Right now
things are quite complicated and misleading for the uninitiated.

If we are to optimize things better in the future, then be it, but I
would like first to clean some historical cruft.

I'm a quite pedantical guy, you know. :)
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
