Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E99DD6B0089
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 15:03:21 -0500 (EST)
Received: by fxm9 with SMTP id 9so6294232fxm.10
        for <linux-mm@kvack.org>; Mon, 23 Nov 2009 12:03:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1259005869-13487-2-git-send-email-acme@infradead.org>
References: <1259005869-13487-1-git-send-email-acme@infradead.org>
	 <1259005869-13487-2-git-send-email-acme@infradead.org>
Date: Mon, 23 Nov 2009 22:03:19 +0200
Message-ID: <84144f020911231203p2e4afd11tc5068c55cf2b1d12@mail.gmail.com>
Subject: Re: [PATCH 2/2] perf kmem: resolve symbols
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>, Mike Galbraith <efault@gmx.de>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 23, 2009 at 9:51 PM, Arnaldo Carvalho de Melo
<acme@infradead.org> wrote:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
>
> E.g.
>
> [root@doppio linux-2.6-tip]# perf kmem record sleep 3s
> [ perf record: Woken up 2 times to write data ]
> [ perf record: Captured and wrote 0.804 MB perf.data (~35105 samples) ]
> [root@doppio linux-2.6-tip]# perf kmem --stat caller | head -10
> -------------------------------------------------------------------------=
-----
> Callsite =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|Total_alloc/Per | Total_=
req/Per | Hit =A0| Frag
> -------------------------------------------------------------------------=
-----
> getname/40 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| 1519616/4096 =A0 | 151961=
6/4096 =A0| =A0 371| =A0 0.000%
> seq_read/a2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0987136/4096 =A0 | =A0987=
136/4096 =A0| =A0 241| =A0 0.000%
> __netdev_alloc_skb/43 =A0 =A0 =A0 | =A0260368/1049 =A0 | =A0259968/1048 =
=A0| =A0 248| =A0 0.154%
> __alloc_skb/5a =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 77312/256 =A0 =A0| =A0 77=
312/256 =A0 | =A0 302| =A0 0.000%
> proc_alloc_inode/33 =A0 =A0 =A0 =A0 | =A0 76480/632 =A0 =A0| =A0 76472/63=
2 =A0 | =A0 121| =A0 0.010%
> get_empty_filp/8d =A0 =A0 =A0 =A0 =A0 | =A0 70272/192 =A0 =A0| =A0 70272/=
192 =A0 | =A0 366| =A0 0.000%
> split_vma/8e =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 42064/176 =A0 =A0| =A0 =
42064/176 =A0 | =A0 239| =A0 0.000%
> [root@doppio linux-2.6-tip]#
>
> Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
> Cc: Fr=E9d=E9ric Weisbecker <fweisbec@gmail.com>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> Cc: Li Zefan <lizf@cn.fujitsu.com>
> Cc: Mike Galbraith <efault@gmx.de>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Steven Rostedt <rostedt@goodmis.org>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Looks good to me!

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
