Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 202A96B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 04:42:12 -0500 (EST)
Date: Fri, 20 Jan 2012 11:42:38 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH trivial] mm: make get_mm_counter static-inline
Message-ID: <20120120094238.GA16009@shutemov.name>
References: <20120119124005.21946.18651.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120119124005.21946.18651.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Jan 19, 2012 at 04:40:05PM +0400, Konstantin Khlebnikov wrote:
> This patch makes get_mm_counter() always static inline,
> it is simple enough for that. And remove unused set_mm_counter()
> 
> bloat-o-meter:
> 
> add/remove: 0/1 grow/shrink: 4/12 up/down: 99/-341 (-242)
> function                                     old     new   delta
> try_to_unmap_one                             886     952     +66
> sys_remap_file_pages                        1214    1230     +16
> dup_mm                                      1684    1700     +16
> do_exit                                     2277    2278      +1
> zap_page_range                               208     205      -3
> unmap_region                                 304     296      -8
> static.oom_kill_process                      554     546      -8
> try_to_unmap_file                           1716    1700     -16
> getrusage                                    925     909     -16
> flush_old_exec                              1704    1688     -16
> static.dump_header                           416     390     -26
> acct_update_integrals                        218     187     -31
> do_task_stat                                2986    2954     -32
> get_mm_counter                                34       -     -34
> xacct_add_tsk                                371     334     -37
> task_statm                                   172     118     -54
> task_mem                                     383     323     -60
> 
> try_to_unmap_one() grows because update_hiwater_rss() now completely inline.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: Kirill A. Shutemov <kirill@shutemov.name>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
