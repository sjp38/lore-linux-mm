Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E897C6B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 00:23:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l2so24065139pgu.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 21:23:39 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id g15si303510pli.354.2017.08.07.21.23.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 21:23:38 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id y129so2023622pgy.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 21:23:38 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [lkp-robot] [mm]  7674270022:  will-it-scale.per_process_ops
 -19.3% regression
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170808022830.GA28570@bbox>
Date: Mon, 7 Aug 2017 21:23:34 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <93CA4B47-95C2-43A2-8E92-B142CAB1DAF7@gmail.com>
References: <20170802000818.4760-7-namit@vmware.com>
 <20170808011923.GE25554@yexl-desktop> <20170808022830.GA28570@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kernel test robot <xiaolong.ye@intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, lkp@01.org

Minchan Kim <minchan@kernel.org> wrote:

> Hi,
>=20
> On Tue, Aug 08, 2017 at 09:19:23AM +0800, kernel test robot wrote:
>> Greeting,
>>=20
>> FYI, we noticed a -19.3% regression of will-it-scale.per_process_ops =
due to commit:
>>=20
>>=20
>> commit: 76742700225cad9df49f05399381ac3f1ec3dc60 ("mm: fix =
MADV_[FREE|DONTNEED] TLB flush miss problem")
>> url: =
https://github.com/0day-ci/linux/commits/Nadav-Amit/mm-migrate-prevent-rac=
y-access-to-tlb_flush_pending/20170802-205715
>>=20
>>=20
>> in testcase: will-it-scale
>> on test machine: 88 threads Intel(R) Xeon(R) CPU E5-2699 v4 @ 2.20GHz =
with 64G memory
>> with following parameters:
>>=20
>> 	nr_task: 16
>> 	mode: process
>> 	test: brk1
>> 	cpufreq_governor: performance
>>=20
>> test-description: Will It Scale takes a testcase and runs it from 1 =
through to n parallel copies to see if the testcase will scale. It =
builds both a process and threads based test in order to see any =
differences between the two.
>> test-url: https://github.com/antonblanchard/will-it-scale
>=20
> Thanks for the report.
> Could you explain what kinds of workload you are testing?
>=20
> Does it calls frequently madvise(MADV_DONTNEED) in parallel on =
multiple
> threads?

According to the description it is "testcase:brk increase/decrease of =
one
page=E2=80=9D. According to the mode it spawns multiple processes, not =
threads.

Since a single page is unmapped each time, and the iTLB-loads increase
dramatically, I would suspect that for some reason a full TLB flush is
caused during do_munmap().

If I find some free time, I=E2=80=99ll try to profile the workload - but =
feel free
to beat me to it.

Nadav=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
