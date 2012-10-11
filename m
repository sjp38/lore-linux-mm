Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id AB9656B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 19:11:13 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Q] Default SLAB allocator
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	<m27gqwtyu9.fsf@firstfloor.org>
	<alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
Date: Thu, 11 Oct 2012 16:10:40 -0700
In-Reply-To: <alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	(David Rientjes's message of "Thu, 11 Oct 2012 15:59:19 -0700 (PDT)")
Message-ID: <m2391ktxjj.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

David Rientjes <rientjes@google.com> writes:

> On Thu, 11 Oct 2012, Andi Kleen wrote:
>
>> > While I've always thought SLUB was the default and recommended allocator,
>> > I'm surprise to find that it's not always the case:
>> 
>> iirc the main performance reasons for slab over slub have mostly
>> disappeared, so in theory slab could be finally deprecated now.
>> 
>
> SLUB is a non-starter for us and incurs a >10% performance degradation in 
> netperf TCP_RR.

When did you last test? Our regressions had disappeared a few kernels
ago.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
