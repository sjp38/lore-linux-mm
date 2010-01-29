Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD8ED6B0095
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:34:36 -0500 (EST)
Date: Fri, 29 Jan 2010 00:35:47 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-ID: <20100129003547.521a1da9@lxorguk.ukuu.org.uk>
In-Reply-To: <4B622AEE.3080906@gmail.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
	<4B622AEE.3080906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Jan 2010 01:25:18 +0100
Vedran Fura=C4=8D <vedran.furac@gmail.com> wrote:

> Alan Cox wrote:
>=20
> > Am I missing something fundamental here ?
>=20
> Yes, the fact linux mm currently sucks. How else would you explain
> possibility of killing random (often root owned) processes using a 5
> lines program started by an ordinary user?=20

If you don't want to run with overcommit you turn it off. At that point
processes get memory allocations refused if they can overrun the
theoretical limit, but you generally need more swap (it's one of the
reasons why things like BSD historically have a '3 * memory' rule).

So sounds to me like a problem between the keyboard and screen (coupled
with the fact far too few desktop vendors include tools to easily set
this stuff up)

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
