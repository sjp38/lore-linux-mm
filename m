Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA0F66B029B
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 20:21:24 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fl2so104456689pad.7
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 17:21:24 -0700 (PDT)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id bm3si22660440pab.286.2016.10.31.17.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 17:21:24 -0700 (PDT)
Received: by mail-pf0-x22a.google.com with SMTP id d2so9913933pfd.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 17:21:24 -0700 (PDT)
Date: Mon, 31 Oct 2016 17:21:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3 0/1] mm/mempolicy.c: forbid static or relative flags
 for local NUMA mode
In-Reply-To: <20161027163037.4089-1-kwapulinski.piotr@gmail.com>
Message-ID: <alpine.DEB.2.10.1610311721050.91888@chino.kir.corp.google.com>
References: <20160927132532.12110-1-kwapulinski.piotr@gmail.com> <20161027163037.4089-1-kwapulinski.piotr@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@suse.com, liangchen.linux@gmail.com, mgorman@techsingularity.net, dave.hansen@linux.intel.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, 27 Oct 2016, Piotr Kwapulinski wrote:

> The MPOL_F_STATIC_NODES and MPOL_F_RELATIVE_NODES flags are irrelevant
> when setting them for MPOL_LOCAL NUMA memory policy via set_mempolicy
> or mbind.
> Return the "invalid argument" from set_mempolicy and mbind whenever
> any of these flags is passed along with MPOL_LOCAL.
> It is consistent with MPOL_PREFERRED passed with empty nodemask.
> It slightly shortens the execution time in paths where these flags
> are used e.g. when trying to rebind the NUMA nodes for changes in
> cgroups cpuset mems (mpol_rebind_preferred()) or when just printing
> the mempolicy structure (/proc/PID/numa_maps).
> Isolated tests done.
> 
> Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
