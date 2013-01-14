Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id ED93E6B0062
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 18:44:14 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id t2so2894764qcq.14
        for <linux-mm@kvack.org>; Mon, 14 Jan 2013 15:44:13 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUXyTvW0P4Adbr2x+RP3X-b3Qj8E53uxWrnDe964MgZepg@mail.gmail.com>
References: <CA+icZUXyTvW0P4Adbr2x+RP3X-b3Qj8E53uxWrnDe964MgZepg@mail.gmail.com>
Date: Tue, 15 Jan 2013 00:44:13 +0100
Message-ID: <CA+icZUXHksmiZYVU+gTyi+j9q9e1b5R9ZJ2RxUTeWKiey2PRuA@mail.gmail.com>
Subject: Re: [PATCH] mm: fix BUG on madvise early failure
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Shaohua Li <shli@fusionio.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>

On Mon, Jan 14, 2013 at 10:29 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> Hi,
>
> this patch is for Linux-Next - more exactly next-20130114.
> Can you please enhance the subject-line of your patch next time.
>
> Your patch fixes the issue I have reported a few hours ago in [1].
>
> [ TESTCASE ]
>
> "madvise02" from Linux Test Project (LTP) see [2]
>
> $ cd /opt/ltp/testcases/bin/
>
> $ sudo ./madvise02
> [ OUTPUT ]
> madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22):
> Invalid argument
> madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22):
> Invalid argument
> madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22):
> Invalid argument
> madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12):
> Cannot allocate memory
> madvise02    5  TFAIL  :  madvise succeeded unexpectedly
>
> [ /TESTCASE ]
>
> Please feel free and add a...
>
>      Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
>
> Thanks!
>
> Regards,
> - Sedat -
>
> [1] http://marc.info/?l=linux-mm&m=135818843710244&w=2
> [2] http://sourceforge.net/projects/ltp/

You happen to know how I get more verbose-debug outputs?

You have...

[   57.320031] kernel BUG at block/blk-core.c:2981!
[   57.320031] invalid opcode: 0000 [#3] PREEMPT SMP DEBUG_PAGEALLOC

Me has...

[ 1263.965989] Kernel BUG at ffffffff81328b2b [verbose debug info unavailable]
[ 1263.966022] invalid opcode: 0000 [#1] SMP

CONFIG_DEBUG_PAGEALLOC=y ?

Block-specific debug settings?

$ egrep -i 'block|blk' .config | egrep -i 'debug|dbg'
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set

- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
