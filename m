Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 0B0DC6B0009
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 23:19:27 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1042840dak.14
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 20:19:27 -0800 (PST)
Date: Sun, 27 Jan 2013 20:19:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
In-Reply-To: <1359339147.6763.25.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301272015450.896@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251800550.29196@eggly.anvils> <1359339147.6763.25.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Jan 2013, Simon Jeons wrote:
> On Fri, 2013-01-25 at 18:01 -0800, Hugh Dickins wrote:
> > Switching merge_across_nodes after running KSM is liable to oops on stale
> > nodes still left over from the previous stable tree.  It's not something
> 
> Since this patch solve the problem, so the description of
> merge_across_nodes(Value can be changed only when there is no ksm shared
> pages in system) should be changed in this patch.

No.

The code could be changed to unmerge_and_remove_all_rmap_items()
automatically whenever merge_across_nodes is changed; but that's
not what Petr chose to do, and I didn't feel strongly to change it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
