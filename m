Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B18216B0062
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 09:50:35 -0400 (EDT)
Date: Thu, 11 Oct 2012 14:50:31 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 13/33] autonuma: autonuma_enter/exit
Message-ID: <20121011135031.GV3317@csn.ul.ie>
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
 <1349308275-2174-14-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1349308275-2174-14-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Oct 04, 2012 at 01:50:55AM +0200, Andrea Arcangeli wrote:
> This is where we register (and unregister) an "mm" structure into
> AutoNUMA for knuma_scand to scan them.
> 
> knuma_scand is the first gear in the whole AutoNUMA algorithm.
> knuma_scand is the daemon that scans the "mm" structures in the list
> and sets pmd_numa and pte_numa to allow the NUMA hinting page faults
> to start. All other actions follow after that. If knuma_scand doesn't
> run, AutoNUMA is fully bypassed. If knuma_scand is stopped, soon all
> other AutoNUMA gears will settle down too.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

I think there will be other cases in the future where autonuma_exit will
be used but not mandatory to deal with right now so

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
