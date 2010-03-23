Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 308136B01B3
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:57:41 -0400 (EDT)
Received: by fxm10 with SMTP id 10so1004732fxm.30
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 10:57:38 -0700 (PDT)
Subject: Re: [Bugme-new] [Bug 15618] New: 2.6.18->2.6.32->2.6.33 huge regression in performance
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
From: Anton Starikov <ant.starikov@gmail.com>
In-Reply-To: <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org>
Date: Tue, 23 Mar 2010 18:57:34 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <54F3A3FB-E99F-4278-AAAB-5B6A09247C4B@gmail.com>
References: <bug-15618-10286@https.bugzilla.kernel.org/> <20100323102208.512c16cc.akpm@linux-foundation.org> <20100323173409.GA24845@elte.hu> <alpine.LFD.2.00.1003231037410.18017@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


On Mar 23, 2010, at 6:45 PM, Linus Torvalds wrote:

>=20
>=20
> On Tue, 23 Mar 2010, Ingo Molnar wrote:
>>=20
>> It shows a very brutal amount of page fault invoked mmap_sem spinning=20=

>> overhead.
>=20
> Isn't this already fixed? It's the same old "x86-64 rwsemaphores are =
using=20
> the shit-for-brains generic version" thing, and it's fixed by
>=20
> 	1838ef1 x86-64, rwsem: 64-bit xadd rwsem implementation
> 	5d0b723 x86: clean up rwsem type system
> 	59c33fa x86-32: clean up rwsem inline asm statements
>=20
> NOTE! None of those are in 2.6.33 - they were merged afterwards. But =
they=20
> are in 2.6.34-rc1 (and obviously current -git). So Anton would have to=20=

> compile his own kernel to test his load.

Thanks for info, I will try it now.

> We could mark them as stable material if the load in question is a =
real=20
> load rather than just a test-case. On one of the random page-fault=20
> benchmarks the rwsem fix was something like a 400% performance=20
> improvement, and it was apparently visible in real life on some crazy =
SGI=20
> "initialize huge heap concurrently on lots of threads" load.

It is not just a test-case, it is real-life code. With real-life =
problems on 2.6.32 and later :)


Anton.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
