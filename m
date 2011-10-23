Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3129B6B002D
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 17:22:37 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p9NLMU0B007156
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 14:22:32 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz37.hot.corp.google.com with ESMTP id p9NLJEKX027212
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 23 Oct 2011 14:22:28 -0700
Received: by pzk2 with SMTP id 2so18870139pzk.0
        for <linux-mm@kvack.org>; Sun, 23 Oct 2011 14:22:24 -0700 (PDT)
Date: Sun, 23 Oct 2011 14:22:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B1@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110231419070.17218@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org> <4E95917D.3080507@redhat.com>
 <20111012122018.690bdf28.akpm@linux-foundation.org>,<4E95F167.5050709@redhat.com> <65795E11DBF1E645A09CEC7EAEE94B9CB4F747B1@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Fri, 21 Oct 2011, Satoru Moriya wrote:

> We do.
> Basically we need this kind of feature for almost all our latency
> sensitive applications to avoid latency issue in memory allocation.
> 

These are all realtime?

> Currently we run those applications on custom kernels which this
> kind of patch is applied to. But it is hard for us to support every
> kernel version for it. Also there are several customers who can't
> accept a custom kernel and so they must use other commercial Unix.
> If this feature is accepted, they will definitely use it on their
> systems.
> 

That's precisely the problem, it's behavior is going to vary widely from 
version to version as the implementation changes for reclaim and 
compaction.  I think we can do much better with the priority of kswapd and 
reclaiming above the high watermark for threads that need a surplus of 
extra memory because they are realtime, two things we can easily do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
