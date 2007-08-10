Message-ID: <46BBE3DD.2090209@tmr.com>
Date: Fri, 10 Aug 2007 00:04:45 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804224834.5187f9b7@the-village.bc.nu> <20070805071320.GC515@elte.hu> <20070805152231.aba9428a.diegocg@gmail.com> <Pine.LNX.4.64.0708051158260.6905@asgard.lang.hm>
In-Reply-To: <Pine.LNX.4.64.0708051158260.6905@asgard.lang.hm>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: david@lang.hm
Cc: Diego Calleja <diegocg@gmail.com>, Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

david@lang.hm wrote:
> On Sun, 5 Aug 2007, Diego Calleja wrote:
> 
>> El Sun, 5 Aug 2007 09:13:20 +0200, Ingo Molnar <mingo@elte.hu> escribio:
>>
>>> Measurements show that noatime helps 20-30% on regular desktop
>>> workloads, easily 50% for kernel builds and much more than that (in
>>> excess of 100%) for file-read-intense workloads. We cannot just walk
>>
>>
>> And as everybody knows in servers is a popular practice to disable it.
>> According to an interview to the kernel.org admins....
>>
>> "Beyond that, Peter noted, "very little fancy is going on, and that is 
>> good
>> because fancy is hard to maintain." He explained that the only fancy 
>> thing
>> being done is that all filesystems are mounted noatime meaning that the
>> system doesn't have to make writes to the filesystem for files which are
>> simply being read, "that cut the load average in half."
>>
>> I bet that some people would consider such performance hit a bug...
>>
> 
> actually, it's popular practice to disable it by people who know how big 
> a hit it is and know how few programs use it.
> 
> i've been a linux sysadmin for 10 years, and have known about noatime 
> for at least 7 years, but I always thought of it in the catagory of 'use 
> it only on your performance critical machines where you are trying to 
> extract every ounce of performance, and keep an eye out for things 
> misbehaving'
> 
> I never imagined that itwas the 20%+ hit that is being described, and 
> with so little impact, or I would have switched to it across the board 
> years ago.
> 
To get that magnitude you need slow disk with very fast CPU. It helps 
most of systems where the disk hardware is marginal or worse for the i/o 
load. Don't take that as typical.

> I'll bet there are a lot of admins out there in the same boat.
> 
> adding an option in the kernel to change the default sounds like a very 
> good first step, even if the default isn't changed today.
> 

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
