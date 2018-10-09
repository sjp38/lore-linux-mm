Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CAEDB6B026A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 03:21:03 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id t1-v6so399647plz.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 00:21:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4-v6sor15783404pgc.18.2018.10.09.00.21.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 00:21:02 -0700 (PDT)
From: Nadav Amit <nadav.amit@gmail.com>
Message-Id: <296A2DAD-8859-4CA0-8D04-3AFA13FEEBE9@gmail.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_7B63194E-27CC-446E-8004-19668E03F8A2";
	protocol="application/pgp-signature";
	micalg=pgp-sha512
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] x86/mm: In the PTE swapout page reclaim case clear the
 accessed bit instead of flushing the TLB
Date: Tue, 9 Oct 2018 00:20:58 -0700
In-Reply-To: <20181009071637.GF5663@hirez.programming.kicks-ass.net>
References: <1539059570-9043-1-git-send-email-amhetre@nvidia.com>
 <20181009071637.GF5663@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Ashish Mhetre <amhetre@nvidia.com>
Cc: vdumpa@nvidia.com, avanbrunt@nvidia.com, Snikam@nvidia.com, praithatha@nvidia.com, Shaohua Li <shli@kernel.org>, Shaohua Li <shli@fusionio.com>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>


--Apple-Mail=_7B63194E-27CC-446E-8004-19668E03F8A2
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

at 12:16 AM, Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Oct 09, 2018 at 10:02:50AM +0530, Ashish Mhetre wrote:
>> From: Shaohua Li <shli@kernel.org>
>> 
>> We use the accessed bit to age a page at page reclaim time,
>> and currently we also flush the TLB when doing so.
>> 
>> But in some workloads TLB flush overhead is very heavy. In my
>> simple multithreaded app with a lot of swap to several pcie
>> SSDs, removing the tlb flush gives about 20% ~ 30% swapout
>> speedup.
>> 
>> Fortunately just removing the TLB flush is a valid optimization:
>> on x86 CPUs, clearing the accessed bit without a TLB flush
>> doesn't cause data corruption.
>> 
>> It could cause incorrect page aging and the (mistaken) reclaim of
>> hot pages, but the chance of that should be relatively low.
>> 
>> So as a performance optimization don't flush the TLB when
>> clearing the accessed bit, it will eventually be flushed by
>> a context switch or a VM operation anyway. [ In the rare
>> event of it not getting flushed for a long time the delay
>> shouldn't really matter because there's no real memory
>> pressure for swapout to react to. ]
> 
> Note that context switches (and here I'm talking about switch_mm(), not
> the cheaper switch_to()) do not unconditionally imply a TLB invalidation
> these days (on PCID enabled hardware).
> 
> So in that regards, the Changelog (and the comment) is a little
> misleading.
> 
> I don't see anything fundamentally wrong with the patch though; just the
> wording.

What am I missing? This is a patch from 2014, no? b13b1d2d8692b ?


--Apple-Mail=_7B63194E-27CC-446E-8004-19668E03F8A2
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE0YCJM4pMIpzxUdmOK4dOkxJsY0AFAlu8VtoACgkQK4dOkxJs
Y0CaIQ/+LpODo9LpAfJWV+J5yA8TLWbANQ1SInAZ2OqzPeIvZval/xOsH/EZ+1x0
FipSFHDi9/dynP3+qVhe7EeOJrYMSyH/JZqRogUccuqxyz9gvoNnHql1fGplFt1U
1kgRt36Tv0bjYmk22KyWPGgKICctyUQVdxmztUcxxF6nutJ/Is6++1iAkWYvirQg
6Fh6ZYyvK/8QsZIjVls1vnRtZ2twp2ljsZt4fHaipVeYjcZDnQCsCQXw03X12eJH
gEwdJuYBkyBupvoq8b3bVyV64aY6Vv7hcrjGqAfhXu5NlMHF9PSfkzFAFJXMeUlu
Gx7nRlTfCnaHtNjCf8VUKVSyztNm++KhWiWLB0bnUfKAw5YnWxbwQqMAexlLRVfd
irombQ7i+LoAHJ+zYXNPdV76tz7pGZp5Ww11DMkG3bHve1r0reFOP/GrP9xRAJdz
DN9ijuHm39vsAMYSRn34kwNauRo+ko121qeYwbbgMF09lAljZcc2SWIhg7c33xXH
QUh6tUBIY4STDP1YvdYh4CP4MQjM1Q7m+UJYkh7BYhDA4Z/zilD1dzTx3TTV8ngp
R3ZW0bsHaG+5+WVX6ZHu5rSkAj/Ke23/y/yTXh5jd05jx5YAR18ixIWZRWWUA/Eb
f2JUgmon4zHNvl5+4Y8vInT5GIyOohL/imdKkPRg70W84JmcQ2c=
=2cYH
-----END PGP SIGNATURE-----

--Apple-Mail=_7B63194E-27CC-446E-8004-19668E03F8A2--
