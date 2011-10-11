Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E0DA66B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 15:20:37 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Tue, 11 Oct 2011 15:20:14 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB516CBBC@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
 <20110901100650.6d884589.rdunlap@xenotime.net>
 <20110901152650.7a63cb8b@annuminas.surriel.com>
 <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/07/2011 11:08 PM, David Rientjes wrote:
> On Thu, 1 Sep 2011, Rik van Riel wrote:
>
> I also
> think that it will cause regressions on other cpu intensive workloads=20
> that don't require this extra freed memory because it works as a=20
> global heuristic and is not tied to any specific application.

It's yes and no. It may cause regressions on the workloads due to
less amount of available memory. But it may improve the workloads'
performance because they can avoid direct reclaim due to extra
free memory.

Of course if one doesn't need extra free memory, one can turn it
off. I think we can add this feature to cgroup if we want to set
it for any specific process or process group. (Before that we
need to implement min_free_kbytes for cgroup and the implementation
of extra free kbytes strongly depends on it.)

> I think it would be far better to reclaim beyond above the high=20
> watermark if the types of workloads that need this tunable can be=20
> somehow detected (the worst case scenario is being a prctl() that does=20
> synchronous reclaim above the watermark so admins can identify these=20
> workloads), or be able to mark allocations within the kernel as=20
> potentially coming in large bursts where allocation is problematic.

It may work. But isn't it difficult and/or complex to decide
how much memory we should reclaim beyond high watermark
automatically?

I believe that extra free kbytes is far simpler than them.

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
