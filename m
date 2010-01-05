Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E9D526005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 21:26:53 -0500 (EST)
Received: by vws12 with SMTP id 12so5730703vws.12
        for <linux-mm@kvack.org>; Mon, 04 Jan 2010 18:26:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100104182429.833180340@chello.nl>
References: <20100104182429.833180340@chello.nl>
Date: Tue, 5 Jan 2010 11:26:52 +0900
Message-ID: <28c262361001041826h6a63af37s4d8f88208a387ead@mail.gmail.com>
Subject: Re: [RFC][PATCH 0/8] Speculative pagefault -v3
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Peter.

On Tue, Jan 5, 2010 at 3:24 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wro=
te:
> Patch series implementing speculative page faults for x86.
>
> Still needs lots of things sorted, like:
>
> =C2=A0- call_srcu()
> =C2=A0- ptl, irq and tlb-flush
> =C2=A0- a 2nd VM_FAULT_LOCK? return code to distuinguish between
> =C2=A0 =C2=A0simple retry and must take mmap_sem semantics?
>
> Comments?
> --
>
>

I looked over this patch series.
This series are most neat in things I have ever seen.
If we solve call_srcu problem, it would be good.

I will help you test this series in my machine to work well.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
