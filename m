Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 857D06B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 10:55:40 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so76171944qge.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 07:55:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a101si18290755qkh.66.2015.08.07.07.55.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 07:55:39 -0700 (PDT)
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
References: <55C18D2E.4030009@rjmx.net>
 <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org>
 <20150805162436.GD25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
 <20150805163609.GE25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org>
 <55C2BC00.8020302@rjmx.net>
 <alpine.DEB.2.11.1508052229540.891@east.gentwo.org>
 <55C3F70E.2050202@rjmx.net>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <55C4C6E8.5090501@redhat.com>
Date: Fri, 7 Aug 2015 07:55:36 -0700
MIME-Version: 1.0
In-Reply-To: <55C3F70E.2050202@rjmx.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Murray <rjmx@rjmx.net>, Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On 08/06/2015 05:08 PM, Ron Murray wrote:
> On 8/5/2015 23:31, Christoph Lameter wrote:
>> On Wed, 5 Aug 2015, Ron Murray wrote:
>>
>>> OK, tried that (with no parameters though. Should I try some?). That got
>>> me a crash with a blank screen and no panic report. The thing is clearly
>> Hmmm... Crash early on? Could you attach a serial console and try
>> "earlyprintk" as an option as well?
>     Might be difficult, since the box doesn't have a serial port. I think
> I have a USB serial port somewhere, but I don't know if it'll work. I
> will see what I can do.
>
>>> touchy: small changes in memory positions make a difference. That's
>>> probably why I didn't get a panic message until 4.1.4: the gods have to
>>> all be looking in the right direction.
>> Subtle corruption issue. If slub_debug does not get it then other
>> debugging techniques may have to be used.
>>
>>>> [  OK  ] Stopped CUPS Scheduler.
>>>> [  OK  ] Stopped (null).
>>>> ------------[ cut here ]------------
>>> Note the "Stopped (null)" before the "cut here" line. I wonder whether
>>> that has anything to do with the problem, or is it a red herring?
>> Hmmm... Thats a message from user space.
> That's what I thought. I'll see if that message shows up in 4.0.9, and
> try to find out what it is.
>
>

There was a similar report about a crash on reboot with 4.1.3[1]
where that reporter linked it to a bluetooth mouse. Hopefully this
isn't a red herring but it might be a similar report?

Thanks,
Laura

[1]https://bugzilla.redhat.com/show_bug.cgi?id=1248741

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
