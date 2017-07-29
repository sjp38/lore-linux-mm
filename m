Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B59986B0581
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 23:21:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 185so11815298wmk.12
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 20:21:23 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id c67si14319412wmc.73.2017.07.28.20.21.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 20:21:22 -0700 (PDT)
Message-ID: <1501298475.12260.21.camel@gmx.de>
Subject: Re: [PATCH 0/3] memdelay: memory health metric for systems and
 workloads
From: Mike Galbraith <efault@gmx.de>
Date: Sat, 29 Jul 2017 05:21:15 +0200
In-Reply-To: <1501296502.12260.19.camel@gmx.de>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
	 <1501296502.12260.19.camel@gmx.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat, 2017-07-29 at 04:48 +0200, Mike Galbraith wrote:
> On Thu, 2017-07-27 at 11:30 -0400, Johannes Weiner wrote:
> >=20
> > Structure
> >=20
> > The first patch cleans up the different loadavg callsites and macros
> > as the memdelay averages are going to be tracked using these.
> >=20
> > The second patch adds a distinction between page cache transitions
> > (inactive list refaults) and page cache thrashing (active list
> > refaults), since only the latter are unproductive refaults.
> >=20
> > The third patch finally adds the memdelay accounting and interface:
> > its scheduler side identifies productive and unproductive task states,
> > and the VM side aggregates them into system and cgroup domain states
> > and calculates moving averages of the time spent in each state.
>=20
> What tree is this against? =C2=A0ttwu asm delta says "measure me".

(mm/master.. gee)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
