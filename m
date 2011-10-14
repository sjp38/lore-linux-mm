Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1E12F6B0196
	for <linux-mm@kvack.org>; Fri, 14 Oct 2011 01:08:44 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 14 Oct 2011 01:06:57 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747A9@USINDEVS02.corp.hds.com>
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
 <65795E11DBF1E645A09CEC7EAEE94B9CB516D0EA@USINDEVS02.corp.hds.com>,<alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110121654120.30123@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/12/2011 08:01 PM, David Rientjes wrote:
>> I understand what you concern. But in some area such as banking,
>> > stock exchange, train/power/plant control sysemts etc this kind
>> > of tunable is welcomed because they can tune their systems at
>> > their own risk.
>> >=20
> You haven't tried the patch that increases the priority of kswapd when=20
> such a latency sensitive thread triggers background reclaim?

No, not yet. I'll try it.

Thanks,
Satoru=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
