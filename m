Subject: Re: Zlatko's I/O slowdown status
References: <Pine.LNX.4.33L.0111021825180.2963-100000@imladris.surriel.com>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 02 Nov 2001 22:22:52 +0100
In-Reply-To: <Pine.LNX.4.33L.0111021825180.2963-100000@imladris.surriel.com> (Rik van Riel's message of "Fri, 2 Nov 2001 18:26:44 -0200 (BRST)")
Message-ID: <877kt8eukz.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 2 Nov 2001, Zlatko Calusic wrote:
> 
> > It was write caching. Somehow disk was running with write cache turned
> > off and I was getting abysmal write performance. Then I found hdparm
> > -W0 /proc/ide/hd* in /etc/init.d/umountfs which is ran during shutdown
> >
> > I would advise users of Debian unstable to comment that part,
> 
> Why do you want Debian users to loose their data ? ;)

That few lines of code is a recent addition to Debian. It never
existed before, so do you want to say that Debian was buggy for years
and people lost massive amounts of data because of that? :)

No, really, I'm using poweroff on my computer and not once I had a
problem with it (I'm speaking about thousands of poweroffs) losing
data after poweroff. But I have a problem with bad performance. :)

> 
> The 'hdparm -W0' is useful in getting the drive to flush
> out the data to disk instead of having it linger around
> in the drive cache.
> 

Yes, I know, but it's not THAT important, otherwise it wouldn't be
missing so many years from the init script.

Anyway, this whole debate probably points to a problem of missing
hdparm -W1 in the startup init script. IDE drives really behave
poorely without write caching and there's nothing we could do about
that, beside turning it on and pray to God we don't have too many
power outages. :)
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
