Date: Fri, 5 May 2000 02:03:38 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
Message-ID: <20000505020338.A289@suse.de>
References: <3911ECCD.BA1BB24E@arcormail.de> <Pine.LNX.4.21.0005050137120.8057-100000@alpha.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0005050137120.8057-100000@alpha.random>; from andrea@suse.de on Fri, May 05, 2000 at 01:44:23AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Shane Shrybman <shrybman@sympatico.ca>, "Juan J. Quintela" <quintela@fi.udc.es>, gandalf@wlug.westbo.se, Joerg Stroettchen <joerg.stroettchen@arcormail.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 05 2000, Andrea Arcangeli wrote:
> As somebody noticed classzone-18 had a deadlock condition. It was due a
> silly bug and I fixed it in the new classzone-22:

Yes, this fixes the truncate bug here. No problems noticed so far.

-- 
*  Jens Axboe <axboe@suse.de>
*  Linux CD/DVD-ROM, SuSE Labs
*  http://kernel.dk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
