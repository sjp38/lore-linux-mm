Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0E0876B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 19:51:39 -0500 (EST)
Message-ID: <4B0B2DF1.1010603@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 08:50:57 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] perf kmem: resolve symbols
References: <1259005869-13487-1-git-send-email-acme@infradead.org> <1259005869-13487-2-git-send-email-acme@infradead.org>
In-Reply-To: <1259005869-13487-2-git-send-email-acme@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, =?UTF-8?B?RnLDqQ==?= =?UTF-8?B?ZMOpcmljIFdlaXNiZWNrZXI=?= <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Galbraith <efault@gmx.de>, Paul Mackerras <paulus@samba.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Arnaldo Carvalho de Melo wrote:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
>=20
> E.g.
>=20
> [root@doppio linux-2.6-tip]# perf kmem record sleep 3s
> [ perf record: Woken up 2 times to write data ]
> [ perf record: Captured and wrote 0.804 MB perf.data (~35105 samples) ]
> [root@doppio linux-2.6-tip]# perf kmem --stat caller | head -10
> -----------------------------------------------------------------------=
-------
> Callsite                    |Total_alloc/Per | Total_req/Per | Hit  | F=
rag
> -----------------------------------------------------------------------=
-------
> getname/40                  | 1519616/4096   | 1519616/4096  |   371|  =
 0.000%
> seq_read/a2                 |  987136/4096   |  987136/4096  |   241|  =
 0.000%
> __netdev_alloc_skb/43       |  260368/1049   |  259968/1048  |   248|  =
 0.154%
> __alloc_skb/5a              |   77312/256    |   77312/256   |   302|  =
 0.000%
> proc_alloc_inode/33         |   76480/632    |   76472/632   |   121|  =
 0.010%
> get_empty_filp/8d           |   70272/192    |   70272/192   |   366|  =
 0.000%
> split_vma/8e                |   42064/176    |   42064/176   |   239|  =
 0.000%
> [root@doppio linux-2.6-tip]#
>=20
> Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> Cc: Fr=C3=A9d=C3=A9ric Weisbecker <fweisbec@gmail.com>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Mike Galbraith <efault@gmx.de>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
>  tools/perf/builtin-kmem.c |   37 +++++++++++++++++++++++--------------
>  1 files changed, 23 insertions(+), 14 deletions(-)

I was about to send out my version. Any, thanks for doing this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
