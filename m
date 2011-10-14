Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3278C6B0198
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 01:33:15 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 14 Oct 2011 01:32:08 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747AA@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
	<20111010153723.6397924f.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
	<20111011125419.2702b5dc.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com>
	<20111011135445.f580749b.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com>
	<alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com>
	<alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>,<20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/13/2011 01:35 AM, KAMEZAWA Hiroyuki wrote:
>=20
> I don't read full story but....how about adding a new syscall like
>=20
> =3D=3D
> sys_mem_shrink(int nid, int nr_scan_pages, int flags)
>=20
> This system call scans LRU of specified nodes and free pages on LRU.
> This scan nr_scan_pages in LRU and returns the number of successfully
> freed pages.
> =3D=3D
>=20
> Then, running this progam in SCHED_IDLE, a user can make free pages while
> the system is idle. If running in the highest priority, a user can keep
> free pages as he want. If a user run this under a memcg, user can free
> pages in a memcg.=20

This is interesting. We can make userspace kswapd as we like with
this syscall. But it seems harder to be accepted...

Regards,
Satoru=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
