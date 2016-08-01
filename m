Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A43586B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 08:41:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i27so249634748qte.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 05:41:30 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id q29si19838637qte.113.2016.08.01.05.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 05:41:29 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id q11so8022621qtb.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 05:41:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <35a0878d-84bd-ad93-8810-23c861ed464e@suse.cz>
References: <201607300506.W5FnCSrY%fengguang.wu@intel.com> <20160731121125.GA29775@dhcp22.suse.cz>
 <20160801110859.GC13544@dhcp22.suse.cz> <35a0878d-84bd-ad93-8810-23c861ed464e@suse.cz>
From: oliver <oohall@gmail.com>
Date: Mon, 1 Aug 2016 22:41:28 +1000
Message-ID: <CAOSf1CG1OB+tQx=u5C5RSEFydPy4Rsa04L=Cwm4PfENWJa658A@mail.gmail.com>
Subject: Re: [memcg:auto-latest 238/243] include/linux/compiler-gcc.h:243:38:
 error: impossible constraint in 'asm'
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Martin_Li=C5=A1ka?= <mliska@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Jason Baron <jbaron@akamai.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>

On Mon, Aug 1, 2016 at 9:27 PM, Martin Li=C5=A1ka <mliska@suse.cz> wrote:
> On 08/01/2016 01:09 PM, Michal Hocko wrote:
>> [CC our gcc guy - I guess he has some theory for this]
>>
>> On Sun 31-07-16 14:11:25, Michal Hocko wrote:
>>> It seems that this has been already reported and Jason has noticed [1] =
that
>>> the problem is in the disabled optimizations:
>>>
>>> $ grep CRYPTO_DEV_UX500_DEBUG .config
>>> CONFIG_CRYPTO_DEV_UX500_DEBUG=3Dy
>>>
>>> if I disable this particular option the code compiles just fine. I have
>>> no idea what is wrong about the code but it seems to depend on
>>> optimizations enabled which sounds a bit scrary...
>>>
>>> [1] http://www.spinics.net/lists/linux-mm/msg109590.html
>
> Hi.
>
> The difference is that w/o any optimization level, GCC doesn't make %c0 a=
n
> intermediate integer operand [1] (see description of "i" constraint).

We recently hit a similar problem on ppc where the compiler couldn't
satisfy an "i" when it was wrapped in an function and optimisations
were disabled. The fix[1] was to change the function signature so that
it's arguments were explicitly const. I don't know enough about gcc to
tell if that behaviour is arch specific or not, but it's worth trying.

Oliver

[1] https://lists.ozlabs.org/pipermail/skiboot/2016-July/004061.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
