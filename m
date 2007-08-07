Message-ID: <46B8C016.6090806@tmr.com>
Date: Tue, 07 Aug 2007 14:55:18 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>	<20070804063217.GA25069@elte.hu>	<20070804070737.GA940@elte.hu>	<20070804103347.GA1956@elte.hu>	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>	<20070804163733.GA31001@elte.hu>	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>	<46B4C0A8.1000902@garzik.org>	<20070804191205.GA24723@lazybastard.org>	<20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <46B4E161.9080100@garzik.org>
In-Reply-To: <46B4E161.9080100@garzik.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Jeff Garzik wrote:
> Alan Cox wrote:
>> In some setups it will and in others it won't. Nor is it the only
>> application that has this requirement. Ext3 currently is a standards
>> compliant file system. Turn off atime and its very non standards
>> compliant, turn to relatime and its not standards compliant but nobody
>> will break (which is good)
> 
> Linux has always been a "POSIX unless its stupid" type of system.  For 
> the upstream kernel, we should do the right thing -- noatime by default 
> -- but allow distros and people that care about rigid compliance to 
> easily change the default.
> 
However, relatime has the POSIX behavior without the overhead. Therefore 
that (and maybe reldiratime?) are a far better choice. I don't see a big 
problem with some version of utils not supporting it, since it can be in 
the kernel and will be in the utils soon enough. We have lived without 
it this long, sounds as if we could live a bit longer.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
