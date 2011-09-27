Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3332A9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 06:03:15 -0400 (EDT)
Received: by fxh17 with SMTP id 17so9044391fxh.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:03:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316230753-8693-1-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
Date: Tue, 27 Sep 2011 15:33:10 +0530
Message-ID: <CAKTCnzkzdQgut96NZf3Mi2kpOWW7N3qeybets5AHy7Gp8Wj_HQ@mail.gmail.com>
Subject: Re: [PATCH 0/8] idle page tracking / working set estimation
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On Sat, Sep 17, 2011 at 9:09 AM, Michel Lespinasse <walken@google.com> wrote:
> Please comment on the following patches (which are against the v3.0 kernel).
> We are using these to collect memory utilization statistics for each cgroup
> accross many machines, and optimize job placement accordingly.
>
> The statistics are intended to be compared accross many machines - we
> don't just want to know which cgroup to reclaim from on an individual
> machine, we also need to know which machine is best to target a job onto
> within a large cluster. Also, we try to have a low impact on the normal
> MM algorithms - we think they already do a fine job balancing resources
> on individual machines, so we are not trying to mess up with that here.
>
> Patch 1 introduces no functionality; it modifies the page_referenced API
> so that it can be more easily extended in patch 3.
>
> Patch 2 documents the proposed features, and adds a configuration option
> for these. When the features are compiled in, they are still disabled
> until the administrator sets up the desired scanning interval; however
> the configuration option seems necessary as the features make use of
> 3 extra page flags - there is plenty of space for these in 64-bit builds,
> but less so in 32-bit builds...
>
> Patch 3 introduces page_referenced_kstaled(), which is similar to
> page_referenced() but is used for idle page tracking rather than
> for memory reclaimation. Since both functions clear the pte_young bits
> and we don't want them to interfere with each other, two new page flags
> are introduced that track when young pte references have been cleared by
> each of the page_referenced variants.

Sorry, I have trouble parsing this sentence, could you elaborate on "when"?


Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
