Message-ID: <39DBE7F4.B04BE59E@sgi.com>
Date: Wed, 04 Oct 2000 19:31:16 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Odd swap behavior
References: <Pine.LNX.4.21.0010042101050.1054-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
	
	[ ... ]
> 
> > If you have a patch (to always deactivate to inactive_dirty),
> > I can help you gauge it with the benchmarks ...
> 
> Quick and dirty patch below ;)
> 

	[ ... ]

Now, I'm not sure whether it helps either. It seemed
to help on 16 & 32 clients, but has worse effects w/ 48
clients. In reality, i guess having a single inactive
(dirty + clean) might help;  but seeing good end results
probably requires other things (such as the swap thing)
to be in place.

Back to looking at code.

cheers,

--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
