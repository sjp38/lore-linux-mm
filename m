Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 52BDD6B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 10:56:38 -0400 (EDT)
Message-ID: <1347202600.5876.7.camel@sbsiddha-ivb>
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
From: Suresh Siddha <suresh.b.siddha@intel.com>
Reply-To: suresh.b.siddha@intel.com
Date: Sun, 09 Sep 2012 07:56:40 -0700
In-Reply-To: <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com>
References: <1340959739.2936.28.camel@lappy>
	 <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>
	 <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>
	 <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>
	 <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>
	 <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>
	 <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Sat, 2012-09-08 at 12:57 -0700, Linus Torvalds wrote:
> Whatever. Something like this (TOTALLY UNTESTED) attached patch should
> get the mtdchar overflows to go away, 

It looks good to me. Acked-by: Suresh Siddha <suresh.b.siddha@intel.com>

Sasha, can you please give this a try?

> but it does *not* fix the fact
> that the MTRR start/end model is broken. It really is technically
> valid to have a resource_size_t range of 0xfffffffffffff000+0x1000,
> and right now it causes a BUG_ON() in pat.c.
> 
> Suresh?

yes but that is not a valid range I think because of the supported
physical address bit limits of the processor and also the max
architecture limit of 52 address bits.

I guess we should be checking for those limits in pat.c, especially bits
above 52 are ignored by the HW and they can easily cause conflicting
aliases with other valid regions. I will get back with a different patch
to fix this.

thanks,
suresh


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
