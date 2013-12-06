Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id EAAD66B0038
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 09:46:49 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so626012qae.10
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 06:46:49 -0800 (PST)
Received: from a14-6.smtp-out.amazonses.com (a14-6.smtp-out.amazonses.com. [54.240.14.6])
        by mx.google.com with ESMTP id b15si41146755qey.20.2013.12.06.06.46.48
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 06:46:49 -0800 (PST)
Date: Fri, 6 Dec 2013 14:46:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 3/8] mm, mempolicy: remove per-process flag
In-Reply-To: <alpine.DEB.2.02.1312051550390.7717@chino.kir.corp.google.com>
Message-ID: <00000142c8600e2a-1c73cb76-2ba9-4644-a714-1c8d43c48c23-000000@email.amazonses.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032117490.29733@chino.kir.corp.google.com>
 <00000142be3633ba-2a459537-58fb-444b-a99f-33ff5e5b2aed-000000@email.amazonses.com> <alpine.DEB.2.02.1312041651080.13608@chino.kir.corp.google.com> <00000142c426b81a-45e6815b-bde4-483c-975e-ce1eea42a753-000000@email.amazonses.com>
 <alpine.DEB.2.02.1312051550390.7717@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, 5 Dec 2013, David Rientjes wrote:

> We actually carry that in our production kernel and have updated it to
> build on 3.11, I'll run it and netperf TCP_RR as well, thanks.

If you get around it then please post the updated version. Maybe we can
get that merged at some point. Keeps floating around after all.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
