Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 24C886B0044
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 08:44:02 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so7413993ied.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 05:44:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	<m27gqwtyu9.fsf@firstfloor.org>
	<alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	<m2391ktxjj.fsf@firstfloor.org>
	<CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
	<alpine.DEB.2.00.1210130252030.7462@chino.kir.corp.google.com>
Date: Sat, 13 Oct 2012 09:44:01 -0300
Message-ID: <CALF0-+Xp_P_NjZpifzDSWxz=aBzy_fwaTB3poGLEJA8yBPQb_Q@mail.gmail.com>
Subject: Re: [Q] Default SLAB allocator
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andi Kleen <andi@firstfloor.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

Hi David,

On Sat, Oct 13, 2012 at 6:54 AM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 12 Oct 2012, Ezequiel Garcia wrote:
>
>> >> SLUB is a non-starter for us and incurs a >10% performance degradation in
>> >> netperf TCP_RR.
>> >
>>
>> Where are you seeing that?
>>
>
> In my benchmarking results.
>
>> Notice that many defconfigs are for embedded devices,
>> and many of them say "use SLAB"; I wonder if that's right.
>>
>
> If a device doesn't require the smallest memory footprint possible (SLOB)
> then SLAB is the right choice when there's a limited amount of memory;
> SLUB requires higher order pages for the best performance (on my desktop
> system running with CONFIG_SLUB, over 50% of the slab caches default to be
> high order).
>

But SLAB suffers from a lot more internal fragmentation than SLUB,
which I guess is a known fact. So memory-constrained devices
would waste more memory by using SLAB.
I must admit a didn't look at page order (but I will now).


>> Is there any intention to replace SLAB by SLUB?
>
> There may be an intent, but it'll be nacked as long as there's a
> performance degradation.
>
>> In that case it could make sense to change defconfigs, although
>> it wouldn't be based on any actual tests.
>>
>
> Um, you can't just go changing defconfigs without doing some due diligence
> in ensuring it won't be deterimental for those users.

Yeah, it would be very interesting to compare SLABs on at least
some of those platforms.


    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
