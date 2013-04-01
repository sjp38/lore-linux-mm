Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C66C96B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 08:38:53 -0400 (EDT)
Date: Mon, 1 Apr 2013 07:38:43 -0500
From: Serge Hallyn <serge.hallyn@ubuntu.com>
Subject: Re: [PATCH v2 00/28] memcg-aware slab shrinking
Message-ID: <20130401123843.GC5217@sergelap>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, hughd@google.com, containers@lists.linux-foundation.org, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Quoting Glauber Costa (glommer@parallels.com):
> Hi,
> 
> Notes:
> ======
> 
> This is v2 of memcg-aware LRU shrinking. I've been testing it extensively
> and it behaves well, at least from the isolation point of view. However,
> I feel some more testing is needed before we commit to it. Still, this is
> doing the job fairly well. Comments welcome.

Do you have any performance tests (preferably with enough runs with and
without this patchset to show 95% confidence interval) to show the
impact this has?  Certainly the feature sounds worthwhile, but I'm
curious about the cost of maintaining this extra state.

-serge

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
