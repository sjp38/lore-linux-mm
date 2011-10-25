Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0816B002D
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 22:05:00 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Mon, 24 Oct 2011 22:04:09 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B3@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
 <20110901100650.6d884589.rdunlap@xenotime.net>
 <20110901152650.7a63cb8b@annuminas.surriel.com>
 <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
 <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
 <20111011125419.2702b5dc.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com>
 <20111011135445.f580749b.akpm@linux-foundation.org>
 <4E95917D.3080507@redhat.com>
 <20111012122018.690bdf28.akpm@linux-foundation.org>,<4E95F167.5050709@redhat.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B1@USINDEVS02.corp.hds.com>,<alpine.DEB.2.00.1110231419070.17218@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110231419070.17218@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

saOn 10/23/2011 05:22 PM, David Rientjes wrote:
> On Fri, 21 Oct 2011, Satoru Moriya wrote:
>=20
>> We do.
>> Basically we need this kind of feature for almost all our latency
>> sensitive applications to avoid latency issue in memory allocation.
>>
>=20
> These are all realtime?

Do you mean that these are all realtime process?

If so, answer is depending on the situation. In the some situations,
we can set these applications as rt-task. But the other situation,
e.g. using some middlewares, package softwares etc, we can't set them
as rt-task because they are not built for running as rt-task. And also
it is difficult to rebuilt them for working as rt-task because they
usually have huge code base.

>> Currently we run those applications on custom kernels which this
>> kind of patch is applied to. But it is hard for us to support every
>> kernel version for it. Also there are several customers who can't
>> accept a custom kernel and so they must use other commercial Unix.
>> If this feature is accepted, they will definitely use it on their
>> systems.
>>
>=20
> That's precisely the problem, it's behavior is going to vary widely from=
=20
> version to version as the implementation changes for reclaim and=20
> compaction.  I think we can do much better with the priority of kswapd an=
d=20
> reclaiming above the high watermark for threads that need a surplus of=20
> extra memory because they are realtime, two things we can easily do.

As I reported another mail, changing kswapd priority does not mitigate
even my simple testcase very much. Of course, reclaiming above the high
wmark may solve the issue on some workloads but if an application can
allocate memory more than high wmark - min wmark which is extended and
fast enough, latency issue will happen.
Unless this latency concern is fixed, customers doesn't use vanilla
kernel.

Regards,
Satoru=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
