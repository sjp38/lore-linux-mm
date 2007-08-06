Message-ID: <46B76E23.7090102@garzik.org>
Date: Mon, 06 Aug 2007 14:53:23 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804070737.GA940@elte.hu> <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org> <20070804194259.GA25753@lazybastard.org> <20070805203602.GB25107@infradead.org> <46B7626C.6050403@redhat.com>
In-Reply-To: <46B7626C.6050403@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Ebbert <cebbert@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, J??rn Engel <joern@logfs.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Chuck Ebbert wrote:
> On 08/05/2007 04:36 PM, Christoph Hellwig wrote:
>> Umm, no f**king way.  atime selection is 100% policy and belongs into
>> userspace.  Add to that the problem that we can't actually re-enable
>> atimes because of the way the vfs-level mount flags API is designed.
>> Instead of doing such a fugly kernel patch just talk to the handfull
>> of distributions that matter to update their defaults.

> We already tried that here. The response: "If noatime is so great, why
> isn't it the default in the kernel?"

Yes, and around and around we go :/

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
