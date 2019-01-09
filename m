Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8408E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 08:38:31 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u20so6711917qtk.6
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 05:38:31 -0800 (PST)
Received: from mail.bluematt.me (mail.bluematt.me. [192.241.179.72])
        by mx.google.com with ESMTPS id o7si5802962qti.38.2019.01.09.05.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 Jan 2019 05:38:30 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [Bug 202149] New: NULL Pointer Dereference in __split_huge_pmd on PPC64LE
From: Matt Corallo <kernel@bluematt.me>
In-Reply-To: <8736q2jbhr.fsf@linux.ibm.com>
Date: Wed, 9 Jan 2019 08:38:28 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <A61367CF-277E-4E74-8A9D-C94C5E53817B@bluematt.me>
References: <bug-202149-27@https.bugzilla.kernel.org/> <20190104170459.c8c7fa57ba9bc8a69dee5666@linux-foundation.org> <87ef9nk4cj.fsf@linux.ibm.com> <ed4bea40-cf9e-89a1-f99a-3dbd6249847f@bluematt.me> <8736q2jbhr.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, bugzilla-daemon@bugzilla.kernel.org

It's normal daily usage on a workstation (TALOS 2). I've seen it at least tw=
ice, both times in rustc, though I've run rustc more times than I can count.=
 Note that the program that triggered it was running in lxc and it only happ=
ened after upgrading to 4.19.

> On Jan 9, 2019, at 06:50, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com> wr=
ote:
>=20
> Matt Corallo <kernel@bluematt.me> writes:
>=20
>> .config follows. I have not tested with 64K pages as, sadly, I have a=20
>> large BTRFS volume that was formatted on x86, and am thus stuck with 4K=20=

>> pages. Note that this is roughly the Debian kernel, so it has whatever=20=

>> patches Debian defaults to applying, a list of which follows.
>>=20
>=20
> What is the test you are running? I tried a 4K page size config on P9. I
> am running ltp test suite there. Also tried few thp memremap tests.
> Nothing hit that.
>=20
> root@:~/tests/ltp/testcases/kernel/mem/thp# getconf  PAGESIZE
> 4096
> root@ltc-boston123:~/tests/ltp/testcases/kernel/mem/thp# grep thp /proc/vm=
stat=20
> thp_fault_alloc 641141
> thp_fault_fallback 0
> thp_collapse_alloc 90
> thp_collapse_alloc_failed 0
> thp_file_alloc 0
> thp_file_mapped 0
> thp_split_page 1
> thp_split_page_failed 0
> thp_deferred_split_page 641150
> thp_split_pmd 24
> thp_zero_page_alloc 1
> thp_zero_page_alloc_failed 0
> thp_swpout 0
> thp_swpout_fallback 0
> root@:~/tests/ltp/testcases/kernel/mem/thp#=20
>=20
> -aneesh
>=20
