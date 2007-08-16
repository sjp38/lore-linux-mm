Message-ID: <46C4248C.1090408@aitel.hist.no>
Date: Thu, 16 Aug 2007 12:18:52 +0200
From: Helge Hafting <helge.hafting@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>	<20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>	<20070804103347.GA1956@elte.hu>	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>	<20070804163733.GA31001@elte.hu> <p73hcnen7w2.fsf@bingen.suse.de>
In-Reply-To: <p73hcnen7w2.fsf@bingen.suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> I always thought the right solution would be to just sync atime only
> very very lazily. This means if a inode is only dirty because of an
> atime update put it on a "only write out when there is nothing to do
> or the memory is really needed" list.
>   
Seems like a good idea.  atimes will then be written only by
memory pressure - or umount.  The atimes could be wrong after
a crash, but loosing atimes only is not something
I'd worry about.

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
