Date: Thu, 19 Sep 2002 11:01:39 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [Lse-tech] Re: 2.5.34-mm4
Message-ID: <20020919090139.GD936@suse.de>
References: <20020915211002.A13470@wotan.suse.de> <Pine.LNX.3.96.1020916144915.6180F-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.3.96.1020916144915.6180F-100000@gatekeeper.tmr.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Andi Kleen <ak@suse.de>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16 2002, Bill Davidsen wrote:
> On Sun, 15 Sep 2002, Andi Kleen wrote:
> 
> > > Overall I find Marcelo kernels to be the most comfortable, followed
> > > by 2.5.  Alan's kernels I find to be the least comfortable in a
> > 
> > ... and -aa kernels are marcelo kernels, just with the the corner
> > cases fixed too. Works very nicely here.
> 
> Corner cases? The IDE, VM and scheduler are different...

The IDE is the same, I'll refrain from commenting on the rest. There's
just an adjustment to the read ahead, which makes sense.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
