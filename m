Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E91BB6B0055
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 14:11:42 -0400 (EDT)
Received: by qyk29 with SMTP id 29so1544051qyk.12
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 11:11:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090428083320.GB17038@localhost>
References: <20090428010907.912554629@intel.com>
	 <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
	 <20090428083320.GB17038@localhost>
Date: Tue, 28 Apr 2009 11:11:52 -0700
Message-ID: <12c511ca0904281111r10f37a5coe5a2750f4dbfbcda@mail.gmail.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 1:33 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> 1) FAST
>
> It takes merely 0.2s to scan 4GB pages:
>
> =A0 =A0 =A0 =A0./page-types =A00.02s user 0.20s system 99% cpu 0.216 tota=
l

OK on a tiny system ... but sounds painful on a big
server. 0.2s for 4G scales up to 3 minutes 25 seconds
on a 4TB system (4TB systems were being sold two
years ago ... so by now the high end will have moved
up to 8TB or perhaps 16TB).

Would the resulting output be anything but noise on
a big system (a *lot* of pages can change state in
3 minutes)?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
