Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DA64B6B016E
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 18:17:45 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 14 Oct 2011 18:16:57 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747AC@USINDEVS02.corp.hds.com>
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
 <alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
 <20111013143501.a59efa5c.kamezawa.hiroyu@jp.fujitsu.com>,<alpine.DEB.2.00.1110131351270.24853@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110131351270.24853@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/13/2011 04:55 PM, David Rientjes wrote:
>=20
> Satoru was specifically talking about the VM using free memory for=20
> pagecache,

Yes, because we can't stop increasing pagecache and it=20
occupies RAM where some people want to keep free for bursty
memory requirement. Usually it works fine but sometimes like
my test case doesn't work well.

> so doing echo echo 1 > /proc/sys/vm/drop_caches can mitigate=20
> that almost immediately. =20

I know it and some admins use that kind of tuning. But is it
proper way? Should we exec the script like above periodically?
I believe that we should use it for debug only.

> I think the key to the discussion, though, is=20
> that even the application doesn't know it's bursty memory behavior before=
=20
> it happens and the kernel entering direct reclaim hurts latency-sensitive=
=20
> applications.
>
> If there were a change to increase the space significantly between the=20
> high and min watermark when min_free_kbytes changes, that would fix the=20
> problem.=20

Right. But min_free_kbytes changes both thresholds, foregroud reclaim
and background reclaim. I'd like to configure them separately like
dirty_bytes and dirty_background_bytes for flexibility.

> The problem is two-fold: that comes at a penalty for systems=20
> or workloads that don't need to reclaim the additional memory, and it's=20
> not clear how much space should exist between those watermarks.

The required size depends on a system architacture such as kernel,
applications, storage etc. and so admin who care the whole system
should configure it based on tests by his own risk.

Regards,
Satoru=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
