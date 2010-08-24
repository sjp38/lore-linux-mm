From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in
 /proc/vmstat
Date: Tue, 24 Aug 2010 10:11:36 +0800
Message-ID: <20100824021136.GA9254@localhost>
References: <20100821054808.GA29869@localhost>
 <AANLkTikS+DUfPz0E2SmCZTQBWL8h2zSsGM8--yqEaVgZ@mail.gmail.com>
 <20100824100943.F3B6.A69D9226@jp.fujitsu.com>
 <AANLkTi=OwGUzM0oZ5qTEFnGTuo8kVfW79oqH-Dcf8jdp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=OwGUzM0oZ5qTEFnGTuo8kVfW79oqH-Dcf8jdp@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Michael Rubin <mrubin@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jack@suse.cz" <jack@suse.cz>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "david@fromorbit.com" <david@fromorbit.com>, "npiggin@kernel.dk" <npiggin@kernel.dk>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-Id: linux-mm.kvack.org

> Right now we don't mount all of debugfs at boot time. We have not done
> the work to verify its safe in our environment. It's mostly a nit.

You work discreetly, that's a good thing. Note that most
sub-directories under debugfs can be turned off in kconfig.

> Also I was under the impression that debugfs was intended more for
> kernel devs while /proc and /sys was intended for application
> developers.

I guess the keyword here is "debugging/diagnosing". Think about
/debug/tracing. DirtyThresh seems like the same stuff.

> >> 3) Full system counters are easier to handle the juggling of removable
> >> storage where these numbers will appear and disappear due to being
> >> dynamic.
> 
> This is the biggie to me. The idea is to get a complete view of the
> system's writeback behaviour over time. With systems with hot plug
> devices, or many many drives collecting that view gets difficult.

Sorry for giving a wrong example. Hope this one is better:

$ cat /debug/bdi/default/stats
[...]
DirtyThresh:       1838904 kB
BackgroundThresh:   919452 kB
[...]

It's a trick to avoid messing with real devices :)

Thanks,
Fengguang
