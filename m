Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 01FF56B006A
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 20:20:43 -0500 (EST)
Date: Mon, 23 Nov 2009 23:20:30 -0200
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH 2/2] perf kmem: resolve symbols
Message-ID: <20091124012030.GB9654@ghostprotocols.net>
References: <1259005869-13487-1-git-send-email-acme@infradead.org> <1259005869-13487-2-git-send-email-acme@infradead.org> <4B0B2DF1.1010603@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B0B2DF1.1010603@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Galbraith <efault@gmx.de>, Paul Mackerras <paulus@samba.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Steven Rostedt <rostedt@goodmis.org>
List-ID: <linux-mm.kvack.org>

Em Tue, Nov 24, 2009 at 08:50:57AM +0800, Li Zefan escreveu:
> Arnaldo Carvalho de Melo wrote:
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> >  tools/perf/builtin-kmem.c |   37 +++++++++++++++++++++++--------------
> >  1 files changed, 23 insertions(+), 14 deletions(-)
> 
> I was about to send out my version. Any, thanks for doing this!

Ok, I'll have some sleep now, hack away! :-)

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
