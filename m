Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070803123712.987126000@chello.nl>
	<alpine.LFD.0.999.0708031518440.8184@woody.linux-foundation.org>
	<20070804063217.GA25069@elte.hu> <20070804070737.GA940@elte.hu>
	<20070804103347.GA1956@elte.hu>
	<alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org>
	<20070804163733.GA31001@elte.hu>
From: Andi Kleen <andi@firstfloor.org>
Date: 05 Aug 2007 02:26:53 +0200
In-Reply-To: <20070804163733.GA31001@elte.hu>
Message-ID: <p73hcnen7w2.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:
> 
> yeah, it's really ugly. But otherwise i've got no real complaint about 
> ext3 - with the obligatory qualification that "noatime,nodiratime" in 
> /etc/fstab is a must. This speeds up things very visibly - especially 
> when lots of files are accessed. It's kind of weird that every Linux 
> desktop and server is hurt by a noticeable IO performance slowdown due 
> to the constant atime updates, while there's just two real users of it: 
> tmpwatch [which can be configured to use ctime so it's not a big issue] 
> and some backup tools. (Ok, and mail-notify too i guess.) Out of tens of 
> thousands of applications. So for most file workloads we give Windows a 
> 20%-30% performance edge, for almost nothing. (for RAM-starved kernel 
> builds the performance difference between atime and noatime+nodiratime 
> setups is more on the order of 40%)

I always thought the right solution would be to just sync atime only
very very lazily. This means if a inode is only dirty because of an
atime update put it on a "only write out when there is nothing to do
or the memory is really needed" list.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
