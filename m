MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18182.23428.284531.374140@stoffel.org>
Date: Fri, 5 Oct 2007 11:43:00 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH] remove throttle_vm_writeout()
In-Reply-To: <E1IdkTY-0002tc-00@dorka.pomaz.szeredi.hu>
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu>
	<20071004145640.18ced770.akpm@linux-foundation.org>
	<E1IdZLg-0002Wr-00@dorka.pomaz.szeredi.hu>
	<20071004160941.e0c0c7e5.akpm@linux-foundation.org>
	<E1Ida56-0002Zz-00@dorka.pomaz.szeredi.hu>
	<20071004164801.d8478727.akpm@linux-foundation.org>
	<E1Idanu-0002c1-00@dorka.pomaz.szeredi.hu>
	<20071004174851.b34a3220.akpm@linux-foundation.org>
	<1191572520.22357.42.camel@twins>
	<E1IdjOa-0002qg-00@dorka.pomaz.szeredi.hu>
	<1191577623.22357.69.camel@twins>
	<E1IdkOf-0002tK-00@dorka.pomaz.szeredi.hu>
	<E1IdkTY-0002tc-00@dorka.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> I think that's an improvement in all respects.
>> 
>> However it still does not generally address the deadlock scenario: if
>> there's a small DMA zone, and fuse manages to put all of those pages
>> under writeout, then there's trouble.

Miklos> And the only way to solve that AFAICS, is to make sure fuse
Miklos> never uses more than e.g. 50% of _any_ zone for page cache.
Miklos> And that may need some tweaking in the allocator...

So what happens if I have three different FUSE mounts, all under heavy
write pressure?  It's not a FUSE problem, it's a VM problem as far as
I can see.   All I did was extrapolate from the 50% number (where did
that come from?) and triple it to go over 100%, since we obviously
shouldn't take 100% of any zone, right?

So the real cure is to have some way to rate limit Zone usage, making
it harder and harder to allocate in a zone as the zone gets more and
more full.  But how do you do this in a non-deadlocky way?  

Buy hey, I'm not that knowledgeable about the VM.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
