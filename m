Date: Sat, 25 Jan 2003 13:28:32 +0100
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.5.59-mm5
Message-ID: <20030125122832.GI889@suse.de>
References: <XFMail.20030124180942.pochini@shiny.it> <3E31765F.4010900@cyberone.com.au> <200301241934.h0OJYf0V005773@turing-police.cc.vt.edu> <20030124200434.GD889@suse.de> <200301242202.h0OM2m0V007374@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200301242202.h0OM2m0V007374@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Nick Piggin <piggin@cyberone.com.au>, Giuliano Pochini <pochini@shiny.it>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-kernel@alex.org.uk, Alex Tomas <bzzz@tmi.comex.ru>, Andrew Morton <akpm@digeo.com>, Oliver Xymoron <oxymoron@waste.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 24 2003, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 24 Jan 2003 21:04:34 +0100, Jens Axboe said:
> 
> > Nicks comment refers to the block layer situation, we obviously cannot
> > merge reads and writes there. You would basically have to rewrite the
> > entire request submission structure and break all drivers. And for zero
> > benefit. Face it, it would be stupid to even attempt such a manuever.
> 
> As I *said* - "hairy beyond benefit", not "cant".

Hairy is ok as long as it provides substantial benefit in some way, and
this does definitely not qualify.

> > Since you bring it up, you must know if a device which can take a single
> > command that says "read blocks a to b, and write blocks x to z"? Even
> > such thing existed,
> 
> They do exist.
> 
> IBM mainframe disks (the 3330/50/80 series) are able to do much more
> than that in one CCW chain  So it was *quite* possible to even express
> things like "Go to this cylinder/track, search for each record that
> has value XYZ in the 'key' field, and if found, write value ABC in the
> data field". (In fact, the DASD I/O
> opcodes for CCW chains are Turing-complete).

Well as interesting as that is, it is still an obscurity that will not
be generally supported. As I said, if you wanted to do such a thing you
can do it in the driver. Complicating the block layer in this way is
totally unacceptable, and is just bound to be an endless source of data
corrupting driver bugs.

> > So I quite agree with the "obviously".
> 
> My complaint was the confusion of "obviously cant" with "we have decided we
> don't want to".

Ok fair enough, make that a strong "obviously wont" instead then.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
