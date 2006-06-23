Message-ID: <449BA06A.2030507@yahoo.com.au>
Date: Fri, 23 Jun 2006 18:03:54 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] radix-tree: RCU lockless readside
References: <20060408134635.22479.79269.sendpatchset@linux.site>	<20060408134707.22479.33814.sendpatchset@linux.site>	<20060622014949.GA2202@us.ibm.com>	<20060622154518.GA23109@wotan.suse.de>	<20060622163032.GC1295@us.ibm.com>	<20060622165551.GB23109@wotan.suse.de>	<20060622174057.GF1295@us.ibm.com>	<20060622181111.GD23109@wotan.suse.de> <20060623000901.bf8b46c5.akpm@osdl.org>
In-Reply-To: <20060623000901.bf8b46c5.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, paulmck@us.ibm.com, benh@kernel.crashing.org, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 22 Jun 2006 20:11:12 +0200
> Nick Piggin <npiggin@suse.de> wrote:
> 
> 
>>On Thu, Jun 22, 2006 at 10:40:57AM -0700, Paul E. McKenney wrote:
>>
>>>On Thu, Jun 22, 2006 at 06:55:51PM +0200, Nick Piggin wrote:
>>>
>>>>No problem, will change.
>>>
>>>Thank you!
>>
>>OK, and with that I believe I've covered all your concerns.
>>
>>Attached is the incremental patch (plus a little bit of fuzz
>>that's gone to Andrew). The big items are:
>>
>>- documentation, clarification of comments
>>- tag lookups are now RCU safe (tested with harness)
>>- cleanups of various misuses of rcu_ API that Paul spotted
>>- thought I might put in a copyright -- is this OK?
>>
>>Andrew, please apply.
> 
> 
> Freeing unused kernel memory: 316k freed
> Write protecting the kernel read-only data: 384k
> No module found in object
> No module found in object
> No module found in object
> No module found in object
> input: AT Translated Set 2 keyboard as /class/input/input0
> No module found in object
> EXT3-fs: INFO: recovery required on readonly filesystem.
> EXT3-fs: write access will be enabled during recovery.
> kjournald starting.  Commit interval 5 seconds
> EXT3-fs: recovery complete.
> EXT3-fs: mounted filesystem with ordered data mode.
> BUG: NMI Watchdog detected LOCKUP on CPU0, eip c0264345, registers:
> CPU:    0
> EIP is at radix_tree_gang_lookup_tag+0x105/0x1a0
> eax: ffffffff   ebx: 00000040   ecx: ffffffc0   edx: 00000007
> esi: e701e9d8   edi: 000001c0   ebp: e6fbddd8   esp: e6fbdda8
> ds: 007b   es: 007b   ss: 0068
> Process fsck.ext3 (pid: 1565, ti=e6fbc000 task=c1fbcb90 task.ti=e6fbc000)
> Stack: e77f2dc4 e701e9d8 e701e9d8 00000002 00000fff 00000000 e701e8c8 e6fbde60 
>        0000000e c1c6c52c e6fbde60 c1c6c538 e6fbde00 c014b68f c1c6c52c e6fbde60 
>        00000000 0000000e 00000000 e6fbde58 00000000 00000001 e6fbde20 c0155631 
> Call Trace:
> Code: 89 fa 8d 4c 09 fa d3 e3 d3 ea 89 d9 83 e2 3f f7 d9 eb 13 8d 76 00 89 f8 89 df 21 c8 01 c7 74 26 42 83 fa 40 74 95 0f a3 16 19 c0 <85> c0 74 e7 83 7d dc 01 74 3a 31 f6 89 75 f0 e9 6e ff ff ff c7 
> console shuts up ...
> 
> 
> Not sure why, either.  It all looks like an equivalent transformation to
> me.

Ahh crap, sorry.

I'll see if I can work it out. Will make another good addition to
rtth (which I'm going to have to sort out and get synched up with
you soon).

> 
> fwiw, here's what I tested:

Thanks.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
