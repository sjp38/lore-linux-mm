Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 345926B057F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 22:48:30 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l3so40332560wrc.12
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 19:48:30 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id j69si11484123wrj.325.2017.07.28.19.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 19:48:28 -0700 (PDT)
Message-ID: <1501296502.12260.19.camel@gmx.de>
Subject: Re: [PATCH 0/3] memdelay: memory health metric for systems and
 workloads
From: Mike Galbraith <efault@gmx.de>
Date: Sat, 29 Jul 2017 04:48:22 +0200
In-Reply-To: <20170727153010.23347-1-hannes@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, 2017-07-27 at 11:30 -0400, Johannes Weiner wrote:
>=20
> Structure
>=20
> The first patch cleans up the different loadavg callsites and macros
> as the memdelay averages are going to be tracked using these.
>=20
> The second patch adds a distinction between page cache transitions
> (inactive list refaults) and page cache thrashing (active list
> refaults), since only the latter are unproductive refaults.
>=20
> The third patch finally adds the memdelay accounting and interface:
> its scheduler side identifies productive and unproductive task states,
> and the VM side aggregates them into system and cgroup domain states
> and calculates moving averages of the time spent in each state.

What tree is this against? =C2=A0ttwu asm delta says "measure me".

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
