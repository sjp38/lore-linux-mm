Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 697906B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 17:09:18 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Wed, 12 Oct 2011 17:08:57 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
	<20111010153723.6397924f.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
	<20111011125419.2702b5dc.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com>
 <20111011135445.f580749b.akpm@linux-foundation.org>
In-Reply-To: <20111011135445.f580749b.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/11/2011 04:54 PM, Andrew Morton wrote:
> On Tue, 11 Oct 2011 16:23:22 -0400
> Satoru Moriya <satoru.moriya@hds.com> wrote:
>
>> Also, if we increase the free-page reserves a.k.a min_free_kbytes,=20
>> the possibility of direct reclaim on other workloads increases.
>> I think it's a bad side effect.
>=20
> extra_free_kbytes has the same side-effect.

I don't think so. If we make low watermark bigger to increase
free-page reserves by extra_free_kbytes, the possibility of
direct reclaim on other workload does not increase directly
because min watermark is not changed.=20
Of course, as David pointed out, other workloads may incur
a regression because kswapd uses more cpu time.

Thanks,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
