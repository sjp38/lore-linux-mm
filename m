Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B10076B002B
	for <linux-mm@kvack.org>; Tue, 18 Dec 2012 10:16:34 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [patch 3/7] mm: vmscan: clarify how swappiness, highest
 priority, memcg interact
Date: Tue, 18 Dec 2012 15:16:22 +0000
Message-ID: <8631DC5930FA9E468F04F3FD3A5D007214AD86F1@USINDEM103.corp.hds.com>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
 <1355767957-4913-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355767957-4913-4-git-send-email-hannes@cmpxchg.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/17/2012 01:12 PM, Johannes Weiner wrote:
> A swappiness of 0 has a slightly different meaning for global reclaim=20
> (may swap if file cache really low) and memory cgroup reclaim (never=20
> swap, ever).
>=20
> In addition, global reclaim at highest priority will scan all LRU=20
> lists equal to their size and ignore other balancing heuristics.
> UNLESS swappiness forbids swapping, then the lists are balanced based=20
> on recent reclaim effectiveness.  UNLESS file cache is running low,=20
> then anonymous pages are force-scanned.
>=20
> This (total mess of a) behaviour is implicit and not obvious from the=20
> way the code is organized.  At least make it apparent in the code flow=20
> and document the conditions.  It will be it easier to come up with=20
> sane semantics later.
>=20
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Hmmm, my company's mail server is in trouble... The mail I sent
yesterday has not been delivered yet.

Anyway, this is good for me.
Thanks!

Reviewed-by: Satoru Moriya <satoru.moriya@hds.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
