Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D42A96B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 21:33:07 -0400 (EDT)
Date: Tue, 31 Aug 2010 09:32:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in
 /proc/vmstat
Message-ID: <20100831013248.GA8359@localhost>
References: <20100830092446.524B.A69D9226@jp.fujitsu.com>
 <AANLkTimLwv04pvuz_AtSK3ASr-epD0PeA-vOCigFH8+0@mail.gmail.com>
 <20100831095932.87CD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100831095932.87CD.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Michael Rubin <mrubin@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 09:07:32AM +0800, KOSAKI Motohiro wrote:
> > On Sun, Aug 29, 2010 at 5:28 PM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > afaict, you and wu agreed /debug/bdi/default/stats is enough good.
> > > why do you change your mention?
> > 
> > I commented on this in the 0/4 email of the bug. I think these belong
> > in /proc/vmstat but I saw they exist in /debug/bdi/default/stats. I
> > figure they will probably not be accepted but I thought it was worth
> > attaching for consideration of upgrading from debugfs to /proc.
> 
> For reviewers view, we are reviewing your patch to merge immediately if all issue are fixed.
> Then, I'm unhappy if you don't drop merge blocker item even though you merely want asking.
> At least, you can make separate thread, no?
> 
> Of cource, wen other user also want to expose via /proc interface, we are resume
> this discusstion gradly.

Michael asked promoting the dirty thresholds from debugfs to /proc.
As a developer I'd interpret the question as: will there be enough
applications/admins using it? If not, we'd better keep it as debugfs.
Otherwise it benefits to do the interface promotion now, because it
will hurt to accumulate many end user dependencies on debugfs over
time..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
