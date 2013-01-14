Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 7095D6B0068
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 16:29:04 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id r4so1855634qaq.1
        for <linux-mm@kvack.org>; Mon, 14 Jan 2013 13:29:03 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Mon, 14 Jan 2013 22:29:03 +0100
Message-ID: <CA+icZUXyTvW0P4Adbr2x+RP3X-b3Qj8E53uxWrnDe964MgZepg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix BUG on madvise early failure
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Shaohua Li <shli@fusionio.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>

Hi,

this patch is for Linux-Next - more exactly next-20130114.
Can you please enhance the subject-line of your patch next time.

Your patch fixes the issue I have reported a few hours ago in [1].

[ TESTCASE ]

"madvise02" from Linux Test Project (LTP) see [2]

$ cd /opt/ltp/testcases/bin/

$ sudo ./madvise02
[ OUTPUT ]
madvise02    1  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22):
Invalid argument
madvise02    2  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22):
Invalid argument
madvise02    3  TPASS  :  failed as expected: TEST_ERRNO=EINVAL(22):
Invalid argument
madvise02    4  TPASS  :  failed as expected: TEST_ERRNO=ENOMEM(12):
Cannot allocate memory
madvise02    5  TFAIL  :  madvise succeeded unexpectedly

[ /TESTCASE ]

Please feel free and add a...

     Tested-by: Sedat Dilek <sedat.dilek@gmail.com>

Thanks!

Regards,
- Sedat -

[1] http://marc.info/?l=linux-mm&m=135818843710244&w=2
[2] http://sourceforge.net/projects/ltp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
