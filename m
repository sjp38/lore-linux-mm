Date: Fri, 2 Nov 2001 15:23:49 -0800
From: Simon Kirby <sim@netnation.com>
Subject: Re: Zlatko's I/O slowdown status
Message-ID: <20011102152349.B17362@netnation.com>
References: <Pine.LNX.4.33.0110261018270.1001-100000@penguin.transmeta.com> <87k7xfk6zd.fsf@atlas.iskon.hr> <20011102065255.B3903@athlon.random> <87g07xdj6x.fsf@atlas.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87g07xdj6x.fsf@atlas.iskon.hr>; from zlatko.calusic@iskon.hr on Fri, Nov 02, 2001 at 09:14:14PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Jens Axboe <axboe@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 02, 2001 at 09:14:14PM +0100, Zlatko Calusic wrote:

> Thank God, today it is finally solved. Just two days ago, I was pretty
> sure that disk had started dying on me, and i didn't know of any
> solution for that. Today, while I was about to try your patch, I got
> another idea and finally pinpointed the problem.
> 
> It was write caching. Somehow disk was running with write cache turned
> off and I was getting abysmal write performance. Then I found hdparm
> -W0 /proc/ide/hd* in /etc/init.d/umountfs which is ran during shutdown
> but I don't understand how it survived through reboots and restarts!
> And why only two of four disks, which I'm dealing with, got confused
> with the command. And finally I don't understand how I could still got
> full speed occassionaly. Weird!
> 
> I would advise users of Debian unstable to comment that part, I'm sure
> it's useless on most if not all setups. You might be pleasantly
> surprised with performance gains (write speed doubles).

Aha!  That would explain why I was seeing it as well... and why I was
seeing errors from hdparm for /dev/hdc and /dev/hdd, which are CDROMs.

Argh. :)

If they have hdparm -W 0 at shutdown, there should be a -W 1 during
startup.

Simon-

[  Stormix Technologies Inc.  ][  NetNation Communications Inc. ]
[       sim@stormix.com       ][       sim@netnation.com        ]
[ Opinions expressed are not necessarily those of my employers. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
