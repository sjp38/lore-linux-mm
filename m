Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id DB7F86B0062
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 04:10:13 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id a19so3159059qad.13
        for <linux-mm@kvack.org>; Wed, 16 Jan 2013 01:10:12 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20130115141102.9a7d93cf4ea74c759ff9e9d5@canb.auug.org.au>
References: <CA+icZUW1+BzWCfGkbBiekKO8b6KiyAiyXWAHFmVUey2dHnSTzw@mail.gmail.com>
	<50F454C2.6000509@kernel.dk>
	<CA+icZUX_uKSzvdhd4tMtgb+vUxqC=fS7tfSHhs29+xD_XQQjBQ@mail.gmail.com>
	<CA+icZUV_dz2Bvu6o=YRFu6324ccVr1MaOEpRcw0rguppR5rQQg@mail.gmail.com>
	<20130115141102.9a7d93cf4ea74c759ff9e9d5@canb.auug.org.au>
Date: Wed, 16 Jan 2013 10:10:12 +0100
Message-ID: <CA+icZUV2ChWTudqBL=UdrQXu2e01LZSn7_-MYZuYbPzX0ekvsg@mail.gmail.com>
Subject: Re: [next-20130114] Call-trace in LTP (lite) madvise02 test
 (block|mm|vfs related?)
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Jens Axboe <axboe@kernel.dk>, linux-next <linux-next@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Sasha Levin <sasha.levin@oracle.com>, Roland McGrath <roland@hack.frob.com>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>

On Tue, Jan 15, 2013 at 4:11 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> On Mon, 14 Jan 2013 22:09:18 +0100 Sedat Dilek <sedat.dilek@gmail.com> wrote:
>>
>> Looks like this is the fix from Sasha [1].
>> Culprit commit is [2].
>> Testing...
>>
>> - Sedat -
>>
>> [1] https://patchwork.kernel.org/patch/1973481/
>
> OK, I added this patch ("mm: fix BUG on madvise early failure") to the
> copy of the akpm tree in linux-next today.
>

Thanks for applying the patch!

Can you add my Tested-by (see [1]), thanks!
( I compiled 8 (in words eight) Linux-Next kernels to catch all
regressions and setup my desired kernel-config options. )

$ uname -r
3.8.0-rc3-next20130114-8-iniza-generic

$ cat /proc/version
Linux version 3.8.0-rc3-next20130114-8-iniza-generic
(sedat.dilek@gmail.com@fambox) (gcc version 4.6.3 (Ubuntu/Linaro
4.6.3-1ubuntu5) ) #1 SMP Tue Jan 15 10:05:32 CET 2013

And YES, I am running that kernel(s) in my daily working environment.
My -8 kernel run successfully all LTP-lite tests...
...which is a good orientation for a localmodconfig-ed kernel (minimal
setup) but does not mean this release has no other bugs which I did
not hit in my environment.

- Sedat -

[1] http://marc.info/?l=linux-mm&m=135819894617603&w=2

>> [2] http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=0d18d770b9180ffc2c3f63b9eb8406ef80105e05
>
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
