Date: Wed, 8 Aug 2007 22:11:12 -0700 (PDT)
From: david@lang.hm
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
In-Reply-To: <2c0942db0708040901x7ada0fe2mf71f37ecba51005b@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708081949320.9909@asgard.lang.hm>
References: <20070803123712.987126000@chello.nl>
 <alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
 <20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
 <Pine.LNX.4.64.0708040032570.6905@asgard.lang.hm>
 <2c0942db0708040901x7ada0fe2mf71f37ecba51005b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 4 Aug 2007, Ray Lee wrote:

> On 8/4/07, david@lang.hm <david@lang.hm> wrote:
>> On Sat, 4 Aug 2007, Ingo Molnar wrote:
>>
> At least on a surface level, your report has some similarities to
> http://lkml.org/lkml/2007/5/21/84 . In that message, John Miller
> mentions several things he tried without effect:
>
> < - I increased the max allowed receive buffer through
> < proc/sys/net/core/rmem_max and the application calls the right
> < syscall. "netstat -su" does not show any "packet receive errors".

mercury1:/proc/sys/net/core# cat rmem_*
124928
131071
mercury1:/proc/sys/net/core# netstat -su
Udp:
     697853177 packets received
     10025642 packets to unknown port received.
     191726680 packet receive errors
     63194 packets sent
     RcvbufErrors: 191726680
UdpLite:
mercury1:/proc/sys/net/core# echo "512000" >rmem_max

> < - After getting "kernel: swapper: page allocation failure.
> < order:0, mode:0x20", I increased /proc/sys/vm/min_free_kbytes

I have not seen any similar errors

> < - ixgb.txt in kernel network documentation suggests to increase
> < net.core.netdev_max_backlog to 300000. This did not help.

mercury1:/proc/sys/net/core# cat netdev_*
300
1000
mercury1:/proc/sys/net/core# echo "300000" >netdev_max_backlog

> < - I also had to increase net.core.optmem_max, because the default
> < value was too small for 700 multicast groups.

I'm not running multicast.

> As they're all pretty simple to test, it may be worthwhile to give
> them a shot just to rule things out.

unfortunantly the load is not high enough right now to see a real 
difference (it's only doing ~1400 logs/sec) I'll catch it at a higher load 
point to see if these make any difference.

David Lang

> Ray
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
