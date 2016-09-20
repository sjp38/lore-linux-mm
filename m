Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECE156B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 11:56:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so20293156wmg.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:56:06 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id m194si12007157lfm.257.2016.09.20.08.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 08:56:05 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id b71so343820lfg.1
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 08:56:05 -0700 (PDT)
Date: Tue, 20 Sep 2016 17:56:02 +0200
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for
 local NUMA mode
Message-ID: <20160920155601.GB3899@home>
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com>
 <alpine.DEB.2.10.1609191755060.53329@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1609191755060.53329@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 19, 2016 at 05:57:17PM -0700, David Rientjes wrote:
> On Sun, 18 Sep 2016, Piotr Kwapulinski wrote:
> 
> > The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> > when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy.
> > Return the "invalid argument" from set_mempolicy whenever
> > any of these flags is passed along with MPOL_LOCAL.
> > It is consistent with MPOL_PREFERRED passed with empty nodemask.
> > It also slightly shortens the execution time in paths where these flags
> > are used e.g. when trying to rebind the NUMA nodes for changes in
> > cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> > the mempolicy structure (/proc/PID/numa_maps).
> > Isolated tests done.
> > 
> > Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> There wasn't an MPOL_LOCAL when I introduced either of these flags, it's 
> an oversight to allow them to be passed.
> 
> Want to try to update set_mempolicy(2) with the procedure outlined in 
> https://www.kernel.org/doc/man-pages/patches.html as well?
Yes, why not ? I'll put a note about it.

--
Piotr Kwapulinski

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
