Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A5A226B01F5
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 11:16:08 -0400 (EDT)
Date: Sat, 3 Apr 2010 10:09:05 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Kernel crash in xfs_iflush_cluster (was Somebody take a look
 please!...)
Message-ID: <20100402230905.GW3335@dastard>
References: <03ca01cacb92$195adf50$0400a8c0@dcccs>
 <2375c9f91003242029p1efbbea1v8e313e460b118f14@mail.gmail.com>
 <20100325153110.6be9a3df.kamezawa.hiroyu@jp.fujitsu.com>
 <02c101cacbf8$d21d1650$0400a8c0@dcccs>
 <179901cad182$5f87f620$0400a8c0@dcccs>
 <t2h2375c9f91004010337p618c4d5yc739fa25b5f842fa@mail.gmail.com>
 <1fe901cad2b0$d39d0300$0400a8c0@dcccs>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1fe901cad2b0$d39d0300$0400a8c0@dcccs>
Sender: owner-linux-mm@kvack.org
To: Janos Haar <janos.haar@netcenter.hu>
Cc: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, xfs@oss.sgi.com, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Sat, Apr 03, 2010 at 12:07:00AM +0200, Janos Haar wrote:
> Hello,
> 
> ----- Original Message ----- From: "Americo Wang"
> <xiyou.wangcong@gmail.com>
> To: "Janos Haar" <janos.haar@netcenter.hu>
> Cc: <linux-kernel@vger.kernel.org>; "KAMEZAWA Hiroyuki"
> <kamezawa.hiroyu@jp.fujitsu.com>; <linux-mm@kvack.org>;
> <xfs@oss.sgi.com>; "Jens Axboe" <axboe@kernel.dk>
> Sent: Thursday, April 01, 2010 12:37 PM
> Subject: Re: Somebody take a look please! (some kind of kernel bug?)
> 
> 
> >On Thu, Apr 1, 2010 at 6:01 PM, Janos Haar
> ><janos.haar@netcenter.hu> wrote:
> >>Hello,
> >>
> >
> >Hi,
> >This is a totally different bug from the previous one reported by you. :)
> 
> Today i have got this again, exactly the same. (if somebody wants
> the log, just ask)
> There is a cut:

Small hint - please put the subsytemthe bug occurred in in the
subject line. I missed this in the firehose of lkml traffic because
there wasnothing to indicate to me it was in XFS. Soemthing like:

"Kernel crash in xfs_iflush_cluster"

Won't get missed quite so easily....

This may be a fixed problem - what kernel are you running?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
