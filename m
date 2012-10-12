Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 3A93A6B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 08:07:05 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5722024ied.14
        for <linux-mm@kvack.org>; Fri, 12 Oct 2012 05:07:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m2391ktxjj.fsf@firstfloor.org>
References: <CALF0-+XGn5=QSE0bpa4RTag9CAJ63MKz1kvaYbpw34qUhViaZA@mail.gmail.com>
	<m27gqwtyu9.fsf@firstfloor.org>
	<alpine.DEB.2.00.1210111558290.6409@chino.kir.corp.google.com>
	<m2391ktxjj.fsf@firstfloor.org>
Date: Fri, 12 Oct 2012 09:07:04 -0300
Message-ID: <CALF0-+WLZWtwYY4taYW9D7j-abCJeY90JzcTQ2hGK64ftWsdxw@mail.gmail.com>
Subject: Re: [Q] Default SLAB allocator
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, celinux-dev@lists.celinuxforum.org

Hi,

On Thu, Oct 11, 2012 at 8:10 PM, Andi Kleen <andi@firstfloor.org> wrote:
> David Rientjes <rientjes@google.com> writes:
>
>> On Thu, 11 Oct 2012, Andi Kleen wrote:
>>
>>> > While I've always thought SLUB was the default and recommended allocator,
>>> > I'm surprise to find that it's not always the case:
>>>
>>> iirc the main performance reasons for slab over slub have mostly
>>> disappeared, so in theory slab could be finally deprecated now.
>>>
>>
>> SLUB is a non-starter for us and incurs a >10% performance degradation in
>> netperf TCP_RR.
>

Where are you seeing that?

Notice that many defconfigs are for embedded devices,
and many of them say "use SLAB"; I wonder if that's right.

Is there any intention to replace SLAB by SLUB?
In that case it could make sense to change defconfigs, although
it wouldn't be based on any actual tests.

    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
