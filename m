Message-ID: <46BA2834.3080507@tmr.com>
Date: Wed, 08 Aug 2007 16:31:48 -0400
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
References: <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804211156.5f600d80@the-village.bc.nu> <20070804202830.GA4538@elte.hu> <20070804210351.GA9784@elte.hu> <20070804225121.5c7b66e0@the-village.bc.nu> <20070805073709.GA6325@elte.hu> <20070805134328.1a4474dd@the-village.bc.nu> <20070805125433.GA22060@elte.hu> <20070805143708.279f51f8@the-village.bc.nu> <20070805180826.GD3244@elte.hu> <46BA09CC.7070007@tmr.com> <46BA1C08.4050904@garzik.org>
In-Reply-To: <46BA1C08.4050904@garzik.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Ingo Molnar <mingo@elte.hu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, J??rn Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

Jeff Garzik wrote:
> Bill Davidsen wrote:
>> Being standards compliant is not an argument it's a design goal, a 
>> requirement. Standards compliance is like pregant, you are or you're 
>
> Linux history says different.  There was always the "final 1%" of 
> compliance that required silliness we really did not want to bother with. 

This is not 1%, this is a user-visible change in behavior, relative to 
all previous Linux versions. There has been a way for ages to trade 
performance for standards for users or distributions, and standards have 
been chosen. Given that there is now a way to get virtually all of the 
performance without giving up atime completely, why the sudden attempt 
to change to a less satisfactory default?

I could understand a push to quickly get relatime with a few 
enhancements (the functionality if not the exact code) into 
distributions, even as a default, but forcing user or distribution 
changes just to retain the same dehavior doesn't seem reasonable. It 
assumes that vendors and users are so stupid they can't understand why 
benchmark results and more important than standards. People who run 
servers are smart enough to decide if their application will run as 
expected without atime.

People have lived with this compromise for a very long time, and it 
seems that a far more balanced solution will be in the kernel soon.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
