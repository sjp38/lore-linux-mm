Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 79A736B03BF
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:33:30 -0400 (EDT)
Received: by obhx4 with SMTP id x4so9272035obh.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 16:33:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1340633728-12785-3-git-send-email-glommer@parallels.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
	<1340633728-12785-3-git-send-email-glommer@parallels.com>
Date: Mon, 25 Jun 2012 16:33:29 -0700
Message-ID: <CABCjUKD0h089StLF8BwVRU-St70Ai9PTw-cjis40_aLLG3MAQQ@mail.gmail.com>
Subject: Re: [PATCH 02/11] memcg: Reclaim when more than one page needed.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Mon, Jun 25, 2012 at 7:15 AM, Glauber Costa <glommer@parallels.com> wrote:
> From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
>
> mem_cgroup_do_charge() was written before slab accounting, and expects
> three cases: being called for 1 page, being called for a stock of 32 pages,
> or being called for a hugepage.  If we call for 2 or 3 pages (and several
> slabs used in process creation are such, at least with the debug options I
> had), it assumed it's being called for stock and just retried without reclaiming.
>
> Fix that by passing down a minsize argument in addition to the csize.
>
> And what to do about that (csize == PAGE_SIZE && ret) retry?  If it's
> needed at all (and presumably is since it's there, perhaps to handle
> races), then it should be extended to more than PAGE_SIZE, yet how far?
> And should there be a retry count limit, of what?  For now retry up to
> COSTLY_ORDER (as page_alloc.c does), stay safe with a cond_resched(),
> and make sure not to do it if __GFP_NORETRY.

The commit description mentions COSTLY_ORDER, but it's not actually
used in the patch.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
