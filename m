Date: Mon, 23 Sep 2002 09:16:33 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: 2.5.38-mm2
Message-ID: <20020923071633.GA15479@suse.de>
References: <3D8E96AA.C2FA7D8@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D8E96AA.C2FA7D8@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 22 2002, Andrew Morton wrote:
> +read-latency.patch
> 
>  Fix the writer-starves-reader elevator problem.  This is basically
>  the read_latency2 patch from -ac kernels.
> 
>  On IDE it provides a 100x improvement in read throughput when there
>  is heavy writeback happening.  40x on SCSI.  You need to disable

Ah interesting. I do still think that it is worth to investigate _why_
both elevator_linus and deadline does not prevent the read starvation.
The read-latency is a hack, not a solution imo.

>  tagged command queueing on scsi - it appears to be quite stupidly
>  implemented.

Ahem I think you are being excessively harsh, or maybe passing judgement
on something you haven't even looked at. Did you consider that you
_drive_ may be the broken component? Excessive turn-around times for
request when using deep tcq is not unusual, by far.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
