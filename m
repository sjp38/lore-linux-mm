Message-ID: <46B8C382.1070106@tmr.com>
Date: Tue, 07 Aug 2007 15:09:54 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804070737.GA940@elte.hu>	<20070804103347.GA1956@elte.hu>	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>	<20070804163733.GA31001@elte.hu>	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>	<46B4C0A8.1000902@garzik.org>	<20070804191205.GA24723@lazybastard.org>	<20070804192130.GA25346@elte.hu>	<20070804211156.5f600d80@the-village.bc.nu>	<20070804202830.GA4538@elte.hu>	<20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu>
In-Reply-To: <20070804225121.5c7b66e0@the-village.bc.nu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Ingo Molnar <mingo@elte.hu>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> i cannot over-emphasise how much of a deal it is in practice. Atime 
>> updates are by far the biggest IO performance deficiency that Linux has 
>> today. Getting rid of atime updates would give us more everyday Linux 
>> performance than all the pagecache speedups of the past 10 years, 
>> _combined_.
>>
>> it's also perhaps the most stupid Unix design idea of all times. Unix is 
>> really nice and well done, but think about this a bit:
> 
> Think about the user for a moment instead. 
> 
> Do things right. The job of the kernel is not to "correct" for
> distribution policy decisions. The distributions need to change policy.
> You do that by showing the distributions the numbers. 
> 
> With a Red Hat on if we can move from /dev/hda to /dev/sda in FC7 then we
> can move from atime to noatime by default on FC8 with appropriate release
> note warnings and having a couple of betas to find out what other than
> mutt goes boom.

Is there really enough benefit between relatime and noatime to justify 
that? If atime doesn't get updated at all it *will* impact operations, 
and unless there's a real performance gain the path which provides at 
least nominal POSIX compliance seems best.

Plauger's law of least astonishment.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
