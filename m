Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 869126B0071
	for <linux-mm@kvack.org>; Sat, 12 Jan 2013 06:12:16 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id r4so458638qaq.1
        for <linux-mm@kvack.org>; Sat, 12 Jan 2013 03:12:15 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUVMY76bRFgUumZy0G-FFM=80iwfSFSopHMwHRYfgKjLjA@mail.gmail.com>
References: <20130111234813.170A620004E@hpza10.eem.corp.google.com>
	<50F0BFAA.10902@infradead.org>
	<20130112131713.749566c8d374cd77b1f2885e@canb.auug.org.au>
	<1357957789.2168.11.camel@joe-AO722>
	<CA+icZUVMY76bRFgUumZy0G-FFM=80iwfSFSopHMwHRYfgKjLjA@mail.gmail.com>
Date: Sat, 12 Jan 2013 12:12:15 +0100
Message-ID: <CA+icZUXVJPrV7-hPa3GNtabijXvktY6tHqKMJ3u5vm-fQV4+fg@mail.gmail.com>
Subject: Re: mmotm 2013-01-11-15-47 uploaded (x86 asm-offsets broken)
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Sat, Jan 12, 2013 at 11:13 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Sat, Jan 12, 2013 at 3:29 AM, Joe Perches <joe@perches.com> wrote:
>> On Sat, 2013-01-12 at 13:17 +1100, Stephen Rothwell wrote:
>>> On Fri, 11 Jan 2013 17:43:06 -0800 Randy Dunlap <rdunlap@infradead.org> wrote:
>>> >
>>> > b0rked.
>>> >
>>> > Some (randconfig?) causes this set of errors:
>>
>> I guess that's when CONFIG_HZ is not an even divisor of 1000.
>> I suppose this needs to be worked on a bit more.
>>
>>
>
> I remember this patch from Joe come up with a pending patch in
> net-next.git#master [1] (I mention this as I have not seen hit it in
> latest Linux-Next whereas this latest mmotm includes it [2]).
>
> $ grep "config HZ_" kernel/Kconfig.hz
>         config HZ_100
>         config HZ_250
>         config HZ_300
>         config HZ_1000
>
> As I see Randy has in his kernel-config:
>
> # CONFIG_HZ_100 is not set
> # CONFIG_HZ_250 is not set
> CONFIG_HZ_300=y
> # CONFIG_HZ_1000 is not set
> CONFIG_HZ=300
>
> So there is a problem for the value "300" (only)?
>
> Regards,
> - Sedat -
>
>
> [1] http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=c10d73671ad30f54692f7f69f0e09e75d3a8926a
> [2] http://git.cmpxchg.org/?p=linux-mmotm.git&a=search&h=HEAD&st=commit&s=softirq
>

That is the patch by Joe in question: "jiffies conversions: Use
compile time constants when possible" (see also [1]).

- Sedat -

[1] http://git.cmpxchg.org/?p=linux-mmotm.git;a=commitdiff;h=049aaaabf2476318f9a2708e3cbd2b2c937faeb0

>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-next" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
