Date: Sat, 4 Aug 2007 21:11:56 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070804211156.5f600d80@the-village.bc.nu>
In-Reply-To: <20070804192130.GA25346@elte.hu>
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu>
	<20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
	<alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org>
	<46B4C0A8.1000902@garzik.org>
	<20070804191205.GA24723@lazybastard.org>
	<20070804192130.GA25346@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: =?UTF-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

> i use Mutt myself, on such a filesystem:
> 
>    /dev/md0 on / type ext3 (rw,noatime,nodiratime,user_xattr)
> 
> and i can see no problems, it notices new mails just fine.

In some setups it will and in others it won't. Nor is it the only
application that has this requirement. Ext3 currently is a standards
compliant file system. Turn off atime and its very non standards
compliant, turn to relatime and its not standards compliant but nobody
will break (which is good)

Either change is a big user/kernel interface change and no major vendor
targets desktop as primary market so I'm not suprised they haven't done
this. The fix is to educate them further not to break the kernel.

There are several reasons for that
-	Distros will change the least conservative stuff first so we
	have the dedicated followers of fashion finding problems first
-	Existing systems won't suddenly change behaviour and break
	(and as the catastrophic failure case is backup failure we do
	not want to break them)

People just need to know about the performance differences - very few
realise its more than a fraction of a percent. I'm sure Gentoo will use
relatime the moment anyone knows its > 5% 8)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
