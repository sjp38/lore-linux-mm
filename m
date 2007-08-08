Message-ID: <46BA09CC.7070007@tmr.com>
Date: Wed, 08 Aug 2007 14:22:04 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805073709.GA6325@elte.hu> <20070805134328.1a4474dd@the-village.bc.nu> <20070805125433.GA22060@elte.hu> <20070805143708.279f51f8@the-village.bc.nu> <20070805180826.GD3244@elte.hu>
In-Reply-To: <20070805180826.GD3244@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> || ...For me, I would say 50% is not enough to describe the _visible_ 
> || benefits... Not talking any specific number but past 10sec-1min+ 
> || lagging in X is history, it's gone and I really don't miss it that 
> || much... :-) Cannot reproduce even a second long delay anymore in 
> || window focusing under considerable load as it's basically 
> || instantaneous (I can see that it's loaded but doesn't affect the 
> || feeling of responsiveness I'm now getting), even on some loads that I 
> || couldn't previously even dream of... [...]
> 
> we really have to ask ourselves whether the "process" is correct if 
> advantages to the user of this order of magnitude can be brushed aside 
> with simple "this breaks binary-only HSM" and "it's not standards 
> compliant" arguments.
> 
Being standards compliant is not an argument it's a design goal, a 
requirement. Standards compliance is like pregant, you are or you're 
not. And to deliberately ignore standards for speed is saying "it's too 
hard to do it right, I'll do it wrong and it will be faster." The answer 
is to do it smarter, with solutions like relatime (which can be enhanced 
as Linus noted) which provide performance benefits without ignoring 
standards, or use of a filesystem which does a better job. But when it 
goes in the kernel the choice of having per-filesystem behavior either 
vanishes or becomes an exercise in complex and as-yet unwritten mount 
options.

There are certainly ways to improve ext3, not journaling atime updates 
would certainly be one, less frequent updates of dirty inodes, whatever. 
But if a user wants to give up standards compliance it should be a 
deliberate choice, not something which the average user will not 
understand or learn to do.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
