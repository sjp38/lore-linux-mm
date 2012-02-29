Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 460226B004D
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:36:03 -0500 (EST)
Date: Wed, 29 Feb 2012 20:35:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH next] memcg: remove PCG_FILE_MAPPED fix cosmetic fix
Message-ID: <20120229193555.GE1673@cmpxchg.org>
References: <alpine.LSU.2.00.1202282121160.4875@eggly.anvils>
 <alpine.LSU.2.00.1202282127110.4875@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1202282127110.4875@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 28, 2012 at 09:28:40PM -0800, Hugh Dickins wrote:
> mem_cgroup_move_account() begins with "anon = PageAnon(page)", and
> then anon is used thereafter: testing PageAnon(page) in the middle
> makes the reader wonder if there's some race to guard against - no.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
