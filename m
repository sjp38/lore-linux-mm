Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E37946B0098
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 04:14:51 -0500 (EST)
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	 <20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Thu, 11 Mar 2010 10:14:25 +0100
Message-ID: <1268298865.5279.997.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-03-11 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 11 Mar 2010 09:39:13 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > The performance overhead is not so huge in both solutions, but the im=
pact on
> > > performance is even more reduced using a complicated solution...
> > >=20
> > > Maybe we can go ahead with the simplest implementation for now and st=
art to
> > > think to an alternative implementation of the page_cgroup locking and
> > > charge/uncharge of pages.

FWIW bit spinlocks suck massive.

> >=20
> > maybe. But in this 2 years, one of our biggest concerns was the perform=
ance.
> > So, we do something complex in memcg. But complex-locking is , yes, com=
plex.
> > Hmm..I don't want to bet we can fix locking scheme without something co=
mplex.
> >=20
> But overall patch set seems good (to me.) And dirty_ratio and dirty_backg=
round_ratio
> will give us much benefit (of performance) than we lose by small overhead=
s.

Well, the !cgroup or root case should really have no performance impact.

> IIUC, this series affects trgger for background-write-out.

Not sure though, while this does the accounting the actual writeout is
still !cgroup aware and can definately impact performance negatively by
shrinking too much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
