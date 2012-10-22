Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0F3F36B005A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 12:06:46 -0400 (EDT)
Date: Mon, 22 Oct 2012 08:36:33 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Message-ID: <20121022153633.GK2095@tassilo.jf.intel.com>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org>
 <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com>
 <20121022132733.GQ16230@one.firstfloor.org>
 <20121022133534.GR16230@one.firstfloor.org>
 <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

> Not sure of your notation there. I assume 31..27 means 5 bits (32
> through to 28 inclusive, 27 excluded). That gives you just 2^31 ==

[27...31]

You're right it's only 5 bits, so just 2GB.

Thinking about it more PowerPC has a 16GB page, so we probably
need to move this to prot.

However I'm not sure if any architectures use let's say the high  
8 bits of prot.

> 
> But there seems an obvious solution here: given your value in those
> bits (call it 'n'), the why not apply a multiplier. I mean, certainly
> you never want a value <= 12 for n, and I suspect that the reasonable
> minimum could be much larger (e.g., 2^16). Call that minimum M. Then
> you could interpret the value in your bits as meaning a page size of
> 
>     (2^n) * M

I considered that, but it would seem ugly and does not add that 
many bits.

> 
> > So this will use up all remaining flag bits now.
> 
> On the other hand, that seems really bad. It looks like that kills the
> ability to further extend the mmap() API with new flags in the future.
> It doesn't sound like we should be doing that.

You can always add flags to PROT or add a mmap3(). Has been done before.
Or just don't do any new MAP_SECURITY_HOLEs

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
