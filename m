Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D898E6B026A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:50:50 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a131-v6so670616lfe.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:50:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18-v6sor414303lja.110.2018.07.03.10.50.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Jul 2018 10:50:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOesGMh6yVYKQ+dJbAsJWU=7wrfwW1cBwVbGoKNiG96_Mh6ebA@mail.gmail.com>
References: <201806301538.bewm1wka%fengguang.wu@intel.com> <CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
 <20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
 <20180630111210.ec9de2c2923a0c58b1357965@linux-foundation.org> <CAOesGMh6yVYKQ+dJbAsJWU=7wrfwW1cBwVbGoKNiG96_Mh6ebA@mail.gmail.com>
From: Olof Johansson <olof@lixom.net>
Date: Tue, 3 Jul 2018 10:50:46 -0700
Message-ID: <CAOesGMgGmr4o92subyJMGGbv7CxFYH_zKV01aWK4TwnEgzHTUQ@mail.gmail.com>
Subject: Re: /tmp/cctnQ1CM.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Andrew,

On Sat, Jun 30, 2018 at 1:30 PM, Olof Johansson <olof@lixom.net> wrote:
> On Sat, Jun 30, 2018 at 11:12 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Sat, 30 Jun 2018 11:07:20 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>> On Sat, 30 Jun 2018 12:27:09 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:
>>>
>>> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>>> > > head:   1904148a361a07fb2d7cba1261d1d2c2f33c8d2e
>>> > > commit: 758517202bd2e427664857c9f2aa59da36848aca arm: port KCOV to arm
>>> > > date:   2 weeks ago
>>> > > config: arm-allmodconfig (attached as .config)
>>> > > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
>>> > > reproduce:
>>> > >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>>> > >         chmod +x ~/bin/make.cross
>>> > >         git checkout 758517202bd2e427664857c9f2aa59da36848aca
>>> > >         # save the attached .config to linux build tree
>>> > >         GCC_VERSION=7.2.0 make.cross ARCH=arm
>>> > >
>>> > > All errors (new ones prefixed by >>):
>>> > >
>>> > >    /tmp/cctnQ1CM.s: Assembler messages:
>>> > >>> /tmp/cctnQ1CM.s:35: Error: .err encountered
>>> > >    /tmp/cctnQ1CM.s:36: Error: .err encountered
>>> > >    /tmp/cctnQ1CM.s:37: Error: .err encountered
>>> >
>>> > Hi kbuild test robot,
>>> >
>>> > The fix was mailed more than a month ago, but still not merged into
>>> > the tree. That's linux...
>>>
>>> That was a rather unhelpful email.
>>>
>>> I've just scanned all your lkml emails since the start of May and
>>> cannot find anything which looks like a fix for this issue.
>>>
>>> Please resend.   About three weks ago :(
>>
>> OK, with a bi of amazing sleuthing I found this from Arnd, which is what
>> I presume you're referring to?
>>
>>
>>
>> From: Arnd Bergmann <arnd@arndb.de>
>> Subject: ARM: disable KCOV for trusted foundations code
>>
>> The ARM trusted foundations code is currently broken in linux-next when
>> CONFIG_KCOV_INSTRUMENT_ALL is set:
>>
>> /tmp/ccHdQsCI.s: Assembler messages:
>> /tmp/ccHdQsCI.s:37: Error: .err encountered
>> /tmp/ccHdQsCI.s:38: Error: .err encountered
>> /tmp/ccHdQsCI.s:39: Error: .err encountered
>> scripts/Makefile.build:311: recipe for target 'arch/arm/firmware/trusted_foundations.o' failed
>>
>> I could not find a function attribute that lets me disable
>> -fsanitize-coverage=trace-pc for just one function, so this turns it off
>> for the entire file instead.
>>
>> Link: http://lkml.kernel.org/r/20180529103636.1535457-1-arnd@arndb.de
>> Fixes: 758517202bd2e4 ("arm: port KCOV to arm")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> Cc: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
> Solves it on my builder at least. Would be good to get this in.
>
> Acked-by: Olof Johansson <olof@lixom.net>

Since this doesn't seem to be in your queue at the moment, I've
applied it to our set of fixes for 4.18 in arm-soc, I'll send to Linus
at end of week and it'll be in -next as of now through there.


Thanks,

-Olof
