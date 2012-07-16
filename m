Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 6015A6B005C
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 17:08:48 -0400 (EDT)
Date: Mon, 16 Jul 2012 14:08:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH mmotm] memcg: further prevent OOM with too many dirty
 pages
Message-Id: <20120716140846.bc5cefb2.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1207160131120.3936@eggly.anvils>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
	<20120619150014.1ebc108c.akpm@linux-foundation.org>
	<20120620101119.GC5541@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1207111818380.1299@eggly.anvils>
	<20120712070501.GB21013@tiehlicka.suse.cz>
	<20120712141343.e1cb7776.akpm@linux-foundation.org>
	<alpine.LSU.2.00.1207121539150.27721@eggly.anvils>
	<20120713082150.GA1448@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1207160111280.3936@eggly.anvils>
	<alpine.LSU.2.00.1207160131120.3936@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, 16 Jul 2012 01:35:34 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> Incremental on top of what I believe you presently have in mmotm:
> better folded in on top of Michal's original and the may_enter_fs "fix".

I think I'll keep it as a separate patch, actually.  This is a pretty
tricky and error-prone area and all those details in the changelog may
prove useful next time this code explodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
