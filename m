Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B057A6B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 04:11:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j25-v6so8310657pfi.20
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 01:11:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16-v6sor4448577plm.69.2018.07.02.01.11.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 01:11:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
References: <201806301538.bewm1wka%fengguang.wu@intel.com> <CACT4Y+b+7T3M=5EbHSpJmMAkRQnXih2+JZqeAvxht2zzKyjD2A@mail.gmail.com>
 <20180630110720.c80f060abe6d163eef78e9a6@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 2 Jul 2018 10:11:21 +0200
Message-ID: <CACT4Y+awX=X2-Oc+3jVBO24cYxYJ1mpkE+8KznPM+9qReyxDQA@mail.gmail.com>
Subject: Re: /tmp/cctnQ1CM.s:35: Error: .err encountered
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jun 30, 2018 at 8:07 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sat, 30 Jun 2018 12:27:09 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>> > head:   1904148a361a07fb2d7cba1261d1d2c2f33c8d2e
>> > commit: 758517202bd2e427664857c9f2aa59da36848aca arm: port KCOV to arm
>> > date:   2 weeks ago
>> > config: arm-allmodconfig (attached as .config)
>> > compiler: arm-linux-gnueabi-gcc (Debian 7.2.0-11) 7.2.0
>> > reproduce:
>> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>> >         chmod +x ~/bin/make.cross
>> >         git checkout 758517202bd2e427664857c9f2aa59da36848aca
>> >         # save the attached .config to linux build tree
>> >         GCC_VERSION=7.2.0 make.cross ARCH=arm
>> >
>> > All errors (new ones prefixed by >>):
>> >
>> >    /tmp/cctnQ1CM.s: Assembler messages:
>> >>> /tmp/cctnQ1CM.s:35: Error: .err encountered
>> >    /tmp/cctnQ1CM.s:36: Error: .err encountered
>> >    /tmp/cctnQ1CM.s:37: Error: .err encountered
>>
>> Hi kbuild test robot,
>>
>> The fix was mailed more than a month ago, but still not merged into
>> the tree. That's linux...
>
> That was a rather unhelpful email.
>
> I've just scanned all your lkml emails since the start of May and
> cannot find anything which looks like a fix for this issue.
>
> Please resend.   About three weks ago :(


Sorry. I am just frustrated by kernel development process.

Bugs are untracked and get lost. Patches are untracked and get lost.
State of patches is nontransparent for most people, including author
(sic!). I've just got a reply on another patch along the lines of "oh,
I've already merged some unspecified version of this patch, so please
resent all changes since that unspecified version in a separate patch"
(what?). It's unclear what is the designated tree and who is the
designated responsible merger. Merging a build fixing patch takes
months (!) whereas most other modern project processes today are
capable of merging such changes into (the single head) tree within an
hour provided only a single maintainer from a group is around, and
they simply need to click a button because all tests, style and
mergability checks have already run by that time. Resending patches
thing should not exist unless the patch needs to be updated, condition
which is detectable automatically.

Andrew, none of this is related to you personally. That's the process
we have today, and I understand you are doing your best.
