Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CE6926B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 19:53:01 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 12 Oct 2011 19:52:29 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com>
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
In-Reply-To: <alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/12/2011 06:41 PM, David Rientjes wrote:
> On Wed, 12 Oct 2011, Satoru Moriya wrote:
>=20
> I think the point was that extra_free_kbytes needs to be tuned to=20
> cover at least the amount of memory of the largest allocation burst

Right. In enterprise area, we strictly test the system we build
again and again before we release it. In that situation, we can
set extra_free_kbytes appropriately based on system's requirements
and/or specifications etc.

> or it doesn't help to prevent latencies for rt threads and,

I thinks it also helps rt threads prevent latency as well as
normal threads because we can start kswapd earlier and avoid
direct reclaim.

> For example, if we were to merge Con's patch so kswapd operates at a=20
> much higher priority for rt threads later on for another issue, it may=20
> significantly reduce the need for extra_free_kbytes to be set as high=20
> as it is.  Everybody who is setting this in init scripts, though, will=20
> continue to set the value because they have no reason to believe it=20
> should be changed.  Then, we have users who start to use the tunable=20
> after Con's patch has been merged and now we have widely different=20
> settings for the same tunable and it can never be obsoleted because=20
> everybody is using it but for different historic reasons.
>=20
> This is why I nack'd the patch originally: it will never be removed,=20
> it is widely misunderstood, and is tied directly to the implementation=20
> of reclaim which will change over time.

I understand what you concern. But in some area such as banking,
stock exchange, train/power/plant control sysemts etc this kind
of tunable is welcomed because they can tune their systems at
their own risk.

Also those systems have been used for a long time without significant
updating. If we update it or build a new system, we configure all
tunables from scratch.

Thanks,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
