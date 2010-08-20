Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B2CC46B02CA
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:56:29 -0400 (EDT)
Date: Fri, 20 Aug 2010 13:56:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on
 dirty_ratio
Message-ID: <20100820055621.GA14110@localhost>
References: <20100820032506.GA6662@localhost>
 <20100820131249.5FF4.A69D9226@jp.fujitsu.com>
 <201008201550.54164.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201008201550.54164.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
To: Con Kolivas <kernel@kolivas.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 01:50:54PM +0800, Con Kolivas wrote:
> On Fri, 20 Aug 2010 02:13:25 pm KOSAKI Motohiro wrote:
> > > The dirty_ratio was silently limited to >= 5%. This is not a user
> > > expected behavior. Let's rip it.
> > >
> > > It's not likely the user space will depend on the old behavior.
> > > So the risk of breaking user space is very low.
> > >
> > > CC: Jan Kara <jack@suse.cz>
> > > CC: Neil Brown <neilb@suse.de>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >
> > Thank you.
> > 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> I have tried to do this in the past, and setting this value to 0 on some 
> machines caused the machine to come to a complete standstill with small 
> writes to disk. It seemed there was some kind of "minimum" amount of data 
> required by the VM before anything would make it to the disk and I never 
> quite found out where that blockade occurred. This was some time ago (3 years 
> ago) so I'm not sure if the problem has since been fixed in the VM since 
> then. I suggest you do some testing with this value set to zero before 
> approving this change.

Good point. I'll do more homework. Thanks for the reminding!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
