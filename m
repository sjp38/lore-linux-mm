Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04BEB6B0038
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 20:57:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n24so5724239pfb.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 17:57:19 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id b73si32044400pfb.21.2016.09.19.17.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 17:57:19 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id id6so802815pad.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 17:57:19 -0700 (PDT)
Date: Mon, 19 Sep 2016 17:57:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for
 local NUMA mode
In-Reply-To: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
Message-ID: <alpine.DEB.2.10.1609191755060.53329@chino.kir.corp.google.com>
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 18 Sep 2016, Piotr Kwapulinski wrote:

> The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
> Return the "invalid argument" from set_mempolicy whenever
> any of these flags is passed along with MPOL_LOCAL.
> It is consistent with MPOL_PREFERRED passed with empty nodemask.
> It also slightly shortens the execution time in paths where these flags
> are used e.g. when trying to rebind the NUMA nodes for changes in
> cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> the mempolicy structure (/proc/PID/numa_maps).
> Isolated tests done.
> 
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

There wasn't an MPOL_LOCAL when I introduced either of these flags, it's 
an oversight to allow them to be passed.

Want to try to update set_mempolicy(2) with the procedure outlined in 
https://www.kernel.org/doc/man-pages/patches.html as well?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
