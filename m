Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0774F6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 11:19:14 -0400 (EDT)
Date: Tue, 26 Jul 2011 17:19:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 2/2] mm: Switch NUMA_BUILD and COMPACTION_BUILD to
 new KCONFIG() syntax
Message-ID: <20110726151908.GD17958@tiehlicka.suse.cz>
References: <4E1D9C25.8080300@suse.cz>
 <1311634718-32588-1-git-send-email-mmarek@suse.cz>
 <1311634718-32588-2-git-send-email-mmarek@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311634718-32588-2-git-send-email-mmarek@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Marek <mmarek@suse.cz>
Cc: linux-kbuild@vger.kernel.org, lacombar@gmail.com, sam@ravnborg.org, linux-kernel@vger.kernel.org, plagnioj@jcrosoft.com, linux-mm@kvack.org

On Tue 26-07-11 00:58:38, Michal Marek wrote:
> Cc: linux-mm@kvack.org
> Signed-off-by: Michal Marek <mmarek@suse.cz>

I assume that this is a cleanup. Without seeing the rest of the patch
set (probably not in linux-mm missing in the CC) and the cover email it
is hard to be sure. Could you add some description to the patch, please?

> ---
>  include/linux/gfp.h    |    2 +-
>  include/linux/kernel.h |   14 --------------
>  mm/page_alloc.c        |   12 ++++++------
>  mm/vmalloc.c           |    4 ++--
>  mm/vmscan.c            |    2 +-
>  5 files changed, 10 insertions(+), 24 deletions(-)

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
