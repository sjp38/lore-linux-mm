Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2637F6B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 11:36:13 -0500 (EST)
Date: Wed, 4 Nov 2009 18:23:39 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv8 0/3] vhost: a kernel-level virtio server
Message-ID: <20091104162339.GA311@redhat.com>
References: <20091104155234.GA32673@redhat.com> <4AF1A587.8000509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AF1A587.8000509@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 11:02:15AM -0500, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > Ok, I think I've addressed all comments so far here.
> > Rusty, I'd like this to go into linux-next, through your tree, and
> > hopefully 2.6.33.  What do you think?
> 
> I think the benchmark data is a prerequisite for merge consideration, IMO.

Shirley Ma was kind enough to send me some measurement results showing
how kernel level acceleration helps speed up you can find them here:
http://www.linux-kvm.org/page/VhostNet

Generally, I think that merging should happen *before* agressive
benchmarking/performance tuning: otherwise there is very substancial
risk that what is an optimization in one setup hurts performance in
another one. When code is upstream, people can bisect to debug
regressions. Another good reason is that I can stop spending time
rebasing and start profiling.

> Do you have anything for us to look at?

For guest to host, compared to latest qemu with userspace virtio
backend, latency drops by a factor of 6, bandwidth doubles, cpu
utilization drops slightly :)

> I think comparison that show the following are of interest:
> 
> throughput (e.g. netperf::TCP_STREAM): guest->host, guest->host->guest,
> guest->host->remote, host->remote, remote->host->guest
> 
> latency (e.g. netperf::UDP_RR): same conditions as throughput
> 
> cpu-utilization
> 
> others?
> 
> Ideally, this should be at least between upstream virtio and vhost.
> Bonus points if you include venet as well.

And vmxnet3 :)

> Kind regards,
> -Greg
> 
-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
