Date: Sun, 6 May 2001 16:42:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: about profiling and stats info for pagecache/buffercache
In-Reply-To: <200105061800.OAA20123@datafoundation.com>
Message-ID: <Pine.LNX.4.21.0105061636020.582-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Zhuravlev <alexey@datafoundation.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 May 2001, Alexey Zhuravlev wrote:

> As far as I understand, now Linux have no facility to collect stats info
> for pagecache/buffercache. For example, it'd be fine if we can see how 
> many requests were submited to pagecache/buffercache and how many of 
> these requests was serviced from cache without I/O. Moreover, it'd be fine
> to have some profiling info on requests for pagecache/buffercache...

OK, so you want:

pagecache	nr_requests	hit	mis	
buffercache	nr_requests	hit	mis

I'd like to see a few other statistics as well, mainly for the
pageout code...

- nr pages scannned
- nr pages moved to the inactive_clean list
- nr pages "rescued" from the inactive_clean list
- nr pages evicted
- nr pages deactivated by pageout scanning
- nr pages deactivated by drop-behind

Are there any more ideas for statistics people would like to
see?

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
