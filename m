Date: Fri, 2 Nov 2001 18:26:44 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Zlatko's I/O slowdown status
In-Reply-To: <87g07xdj6x.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.33L.0111021825180.2963-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrea Arcangeli <andrea@suse.de>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 2 Nov 2001, Zlatko Calusic wrote:

> It was write caching. Somehow disk was running with write cache turned
> off and I was getting abysmal write performance. Then I found hdparm
> -W0 /proc/ide/hd* in /etc/init.d/umountfs which is ran during shutdown
>
> I would advise users of Debian unstable to comment that part,

Why do you want Debian users to loose their data ? ;)

The 'hdparm -W0' is useful in getting the drive to flush
out the data to disk instead of having it linger around
in the drive cache.

regards,

Rik
-- 
DMCA, SSSCA, W3C?  Who cares?  http://thefreeworld.net/

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
