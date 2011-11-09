Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8B50B6B002D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 08:15:59 -0500 (EST)
Date: Wed, 9 Nov 2011 14:14:37 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH mm] mm: memcg: remove unused node/section info from
 pc->flags fix
Message-ID: <20111109131437.GD3153@redhat.com>
References: <1320787408-22866-1-git-send-email-jweiner@redhat.com>
 <1320787408-22866-11-git-send-email-jweiner@redhat.com>
 <alpine.LSU.2.00.1111082108160.1250@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111082108160.1250@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 08, 2011 at 09:18:10PM -0800, Hugh Dickins wrote:
> Fix non-CONFIG_SPARSEMEM build, which failed with
> mm/page_cgroup.c: In function `alloc_node_page_cgroup':
> mm/page_cgroup.c:44: error: `start_pfn' undeclared (first use in this function)
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> For folding into mm-memcg-remove-unused-node-section-info-from-pc-flags.patch
> 
>  mm/page_cgroup.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> Hannes: heartfelt thanks to you for this great work - Hugh

Thanks, I appreciate it.  Sorry for the trouble, the patch is
obviously correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
