Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 6DF2C6B0132
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 21:14:06 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so5318997pbc.14
        for <linux-mm@kvack.org>; Fri, 17 Feb 2012 18:14:05 -0800 (PST)
Date: Fri, 17 Feb 2012 18:13:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock
 splitting
In-Reply-To: <alpine.LSU.2.00.1202161235430.2269@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1202171803380.25191@eggly.anvils>
References: <20120215224221.22050.80605.stgit@zurg> <alpine.LSU.2.00.1202151815180.19722@eggly.anvils> <4F3C8B67.6090500@openvz.org> <alpine.LSU.2.00.1202161235430.2269@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, 16 Feb 2012, Hugh Dickins wrote:
> 
> Yours are not the only patches I was testing in that tree, I tried to
> gather several other series which I should be reviewing if I ever have
> time: Kamezawa-san's page cgroup diet 6, Xiao Guangrong's 4 prio_tree
> cleanups, your 3 radix_tree changes, your 6 shmem changes, your 4 memcg
> miscellaneous, and then your 15 books.
> 
> The tree before your final 15 did well under pressure, until I tried to
> rmdir one of the cgroups afterwards: then it crashed nastily, I'll have
> to bisect into that, probably either Kamezawa's or your memcg changes.

So far I haven't succeeded in reproducing that at all: it was real,
but obviously harder to get than I assumed - indeed, no good reason
to associate it with any of those patches, might even be in 3.3-rc.

It did involve a NULL pointer dereference in mem_cgroup_page_lruvec(),
somewhere below compact_zone() - but repercussions were causing the
stacktrace to scroll offscreen, so I didn't get good details.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
