Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 842776B0062
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 02:45:03 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id d23so2327643fga.8
        for <linux-mm@kvack.org>; Mon, 23 Nov 2009 23:45:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091124073426.GA21991@elte.hu>
References: <4B0B6E44.6090106@cn.fujitsu.com>
	 <84144f020911232315h7c8b7348u9ad97f585f54a014@mail.gmail.com>
	 <20091124073426.GA21991@elte.hu>
Date: Tue, 24 Nov 2009 09:45:00 +0200
Message-ID: <84144f020911232345j75c93ec6mf1fc426262c14eb0@mail.gmail.com>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
	statistics
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Arjan van de Ven <arjan@infradead.org>, Li Zefan <lizf@cn.fujitsu.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Ingo,

On Tue, Nov 24, 2009 at 9:34 AM, Ingo Molnar <mingo@elte.hu> wrote:
> Certainly we can postpone it, as long as there's rough strategic
> consensus on the way forward. I'd hate to have two overlapping core
> kernel facilities and friction between the groups pursuing them and
> constant distraction from having two targets.

Sure, like I said, I think "kmem perf" is the way forward. The only
reason we did kmemtrace userspace out-of-tree was because there was no
perf (or ftrace!) at the time and there wasn't much interest in
putting userspace tools in the tree.

I hope that counts as a "rough strategic consensus" :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
