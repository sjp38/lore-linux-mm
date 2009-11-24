Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A7FCE6B007E
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 02:18:58 -0500 (EST)
Received: by fxm9 with SMTP id 9so6689475fxm.10
        for <linux-mm@kvack.org>; Mon, 23 Nov 2009 23:18:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B0B6E44.6090106@cn.fujitsu.com>
References: <4B0B6E44.6090106@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 09:18:56 +0200
Message-ID: <84144f020911232318q7ad8028ej13bf7799030878bc@mail.gmail.com>
Subject: Re: [PATCH 0/5] perf kmem: Add more functions and show more
	statistics
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 7:25 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
> List of new things:
>
> - Add option "--raw-ip", to print raw ip instead of symbols.
>
> - Sort the output by fragmentation by default, and support
> =A0multi keys.
>
> - Collect and show cross node allocation stats.
>
> - Collect and show alloc/free ping-pong stats.
>
> - And help file.

The series looks good to me!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
