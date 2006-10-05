Subject: Re: Free memory level in 2.6.16?
From: Steve Bergman <sbergman@rueb.com>
In-Reply-To: <p73k63ezg3y.fsf@verdi.suse.de>
References: <1160034527.23009.7.camel@localhost>
	 <p73k63ezg3y.fsf@verdi.suse.de>
Content-Type: text/plain
Date: Thu, 05 Oct 2006 15:10:29 -0500
Message-Id: <1160079029.29452.19.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-10-05 at 22:01 +0200, Andi Kleen wrote:

> 
> Normally it keeps some memory free for interrupt handlers which
> cannot free other memory. But 150MB is indeed a lot, especially
> it's only in the ~900MB lowmem zone.
> 
> You could play with /proc/sys/vm/lowmem_reserve_ratio but must
> likely some defaults need tweaking.

Thank you for the reply, Andi.  This kernel is compiled with the .config
from the original FC5 release, which used kernel 2.6.15.  I just ran
"make oldconfig" on it and accepted the defaults.

So it is, I believe, a 4GB/4GB split.  Does that make a difference?

Thanks,
Steve Bergman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
