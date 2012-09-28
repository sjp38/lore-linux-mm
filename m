Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5CC606B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 05:00:22 -0400 (EDT)
Received: by bkcjm1 with SMTP id jm1so3547386bkc.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 02:00:20 -0700 (PDT)
Message-ID: <50656733.3040609@gmail.com>
Date: Fri, 28 Sep 2012 11:00:35 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: mtd: kernel BUG at arch/x86/mm/pat.c:279!
References: <1340959739.2936.28.camel@lappy>  <CA+1xoqdgKV_sEWvUbuxagL9JEc39ZFa6X9-acP7j-M7wvW6qbQ@mail.gmail.com>  <CA+55aFzJCLxVP+WYJM-gq=aXx5gmdgwC7=_Gr2Tooj8q+Dz4dw@mail.gmail.com>  <1347057778.26695.68.camel@sbsiddha-desk.sc.intel.com>  <CA+55aFwW9Q+DM2gZy7r3JQJbrbMNR6sN+jewc2CY0i1wD_X=Tw@mail.gmail.com>  <1347062045.26695.82.camel@sbsiddha-desk.sc.intel.com>  <CA+55aFzeKcV5hROLJE31dNi3SEs+s6o0LL=96Kh8QGHPx=aZnA@mail.gmail.com> <1347202600.5876.7.camel@sbsiddha-ivb> <505068F4.4080309@gmail.com> <50506A6C.30109@gmail.com>
In-Reply-To: <50506A6C.30109@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: suresh.b.siddha@intel.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, dwmw2@infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mtd@lists.infradead.org, linux-mm <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On 09/12/2012 12:56 PM, Sasha Levin wrote:
> On 09/12/2012 12:50 PM, Sasha Levin wrote:
>> On 09/09/2012 04:56 PM, Suresh Siddha wrote:
>>> On Sat, 2012-09-08 at 12:57 -0700, Linus Torvalds wrote:
>>>>> Whatever. Something like this (TOTALLY UNTESTED) attached patch should
>>>>> get the mtdchar overflows to go away, 
>>> It looks good to me. Acked-by: Suresh Siddha <suresh.b.siddha@intel.com>
>>>
>>> Sasha, can you please give this a try?
>>
>> Sorry for the delay. It looks good here.
>>
>>
>> Thanks,
>> Sasha
>>
> 
> Uh... sorry again, I obviously tested the second patch sent by Linus but
> mistakingly replied to the wrong mail in the thread.

Is anyone planning on picking up Linus' patch? This is still not in -next even.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
