Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6345F6B0253
	for <linux-mm@kvack.org>; Sun,  7 Aug 2016 06:36:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 63so615502304pfx.0
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 03:36:24 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id h12si30869101pfa.73.2016.08.07.03.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Aug 2016 03:36:23 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ez1so22120733pab.3
        for <linux-mm@kvack.org>; Sun, 07 Aug 2016 03:36:23 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160805123034.75fae008@gandalf.local.home>
Date: Sun, 7 Aug 2016 16:06:18 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <93BEB5B5-321C-429B-9B87-40F8B499E45D@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com> <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com> <20160727112303.11409a4e@gandalf.local.home> <0AF03F78-AA34-4531-899A-EA1076B6B3A1@gmail.com> <20160804111946.6cbbd30b@gandalf.local.home> <9D639468-2A70-4620-8BF5-C8B2FBB38A99@gmail.com> <20160805123034.75fae008@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


> On Aug 5, 2016, at 10:00 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
>>=20
>=20
> You probably want to clear the trace here, or set function_graph here
> first. Because the function graph starts writing to the buffer
> immediately.
>=20

I did that, just didn=E2=80=99t include it here :)
>>=20
>=20
> When threshold is set, the entry is not recorded, because it is only
> showing the exit and the time it took in that function:
>=20
> 0) kswapd0-52 | + 54.141 us | } /* shrink_zone */
>=20
> shrink_zone() took 54.141us.
>=20
> The reason it doesn't record the entry is because it would fill the
> entire buffer, if the threshold is never hit. One can't predict the
> time in a function when you first enter that function.

Right!
>=20
>>=20
>=20
> You need your own interpreter here. Perhaps a module that either reads
> the tracepoints directly and registers a function graph tracer itself.
> The trace events and function tracers are plugable. You don't need to
> use the tracing system to use them. Just hook into them directly.
>=20
> Things like the wakeup latency tracer does this. Look at
> kernel/trace/trace_sched_wakeup.c for an example. It hooks into the
> sched_wakeup and sched_switch tracepoints, and also has a way to use
> function and function_graph tracing.
>=20
>=20

I will look at that file. Thanks!
>=20
>>=20
>=20
> Great! And note, even if you add extra tracepoints, you can hook
> directly into them too. Again, see the trace_sched_wakeup.c for
> examples.

Alright. Thanks for all the help! :)

Janani.
>=20
> -- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
