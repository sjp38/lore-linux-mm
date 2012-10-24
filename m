Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 558626B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 02:43:11 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hq4so4050559wib.2
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 23:43:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350656442-1523-2-git-send-email-glommer@parallels.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com>
	<1350656442-1523-2-git-send-email-glommer@parallels.com>
Date: Wed, 24 Oct 2012 09:43:09 +0300
Message-ID: <CAOJsxLFuHVKSnpN=+-7Z-C0mNgYu_pnS0jJgUmDkoPkdkgDteQ@mail.gmail.com>
Subject: Re: [PATCH v5 01/18] move slabinfo processing to slab_common.c
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, devel@openvz.org

On Fri, Oct 19, 2012 at 5:20 PM, Glauber Costa <glommer@parallels.com> wrote:
> This patch moves all the common machinery to slabinfo processing
> to slab_common.c. We can do better by noticing that the output is
> heavily common, and having the allocators to just provide finished
> information about this. But after this first step, this can be done
> easier.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: David Rientjes <rientjes@google.com>

I've applied patches 1-3. Thanks, Glauber!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
