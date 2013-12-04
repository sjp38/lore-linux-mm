Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id E5C816B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 10:24:54 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id r5so3570294qcx.14
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 07:24:54 -0800 (PST)
Received: from a9-111.smtp-out.amazonses.com (a9-111.smtp-out.amazonses.com. [54.240.9.111])
        by mx.google.com with ESMTP id hj7si18632585qeb.116.2013.12.04.07.24.53
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 07:24:53 -0800 (PST)
Date: Wed, 4 Dec 2013 15:24:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/8] mm, mempolicy: remove per-process flag
In-Reply-To: <alpine.DEB.2.02.1312032117490.29733@chino.kir.corp.google.com>
Message-ID: <00000142be3633ba-2a459537-58fb-444b-a99f-33ff5e5b2aed-000000@email.amazonses.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032117490.29733@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 3 Dec 2013, David Rientjes wrote:

> PF_MEMPOLICY is an unnecessary optimization for CONFIG_SLAB users.
> There's no significant performance degradation to checking
> current->mempolicy rather than current->flags & PF_MEMPOLICY in the
> allocation path, especially since this is considered unlikely().

The use of current->mempolicy increase the cache footprint since its in a
rarely used cacheline. This performance issue would occur when memory
policies are not used since that cacheline would then have to be touched
regardless of memory policies be in effect or not. PF_MEMPOLICY was used
to avoid touching the cacheline.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
