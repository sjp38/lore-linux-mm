Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 80B316B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 10:21:22 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id f11so6741025qae.6
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 07:21:22 -0800 (PST)
Received: from b232-131.smtp-out.amazonses.com (b232-131.smtp-out.amazonses.com. [199.127.232.131])
        by mx.google.com with ESMTP id r5si4092258qar.147.2013.12.04.07.21.20
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 07:21:21 -0800 (PST)
Date: Wed, 4 Dec 2013 15:21:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/8] mm, mempolicy: rename slab_node for clarity
In-Reply-To: <alpine.DEB.2.02.1312032117330.29733@chino.kir.corp.google.com>
Message-ID: <00000142be32f445-c4b31577-3ad8-42c4-bfd5-6387662ffa70-000000@email.amazonses.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032117330.29733@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 3 Dec 2013, David Rientjes wrote:

> slab_node() is actually a mempolicy function, so rename it to
> mempolicy_slab_node() to make it clearer that it used for processes with
> mempolicies.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
