Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE1976008DF
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 04:04:28 -0400 (EDT)
Subject: Re: [RFC][PATCH 2/6] mm: stack based kmap_atomic
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100824163545.052e44fd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100819201317.673172547@chello.nl>
	 <20100819202753.656285068@chello.nl>
	 <20100824162427.58e2eb88.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100824163545.052e44fd.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 24 Aug 2010 10:04:23 +0200
Message-ID: <1282637063.2605.2333.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-08-24 at 16:35 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 24 Aug 2010 16:24:27 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>=20
> > And Is it documented that kmap_atomic shouln't be used under NMI or som=
ething
> > special interrupts ?
> >=20
> Sorry, I missed something..Maybe not trouble.

In particular, we actually do use kmap_atomic from NMI context ;-)

It only relies on preempt_disable(), which for now is implied by
pagefault_disable(), if at some point those get split kmap_atomic will
need to do both (currently only PREEMPT_RT splits it, but then that has
a totally different kmap implementation too).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
