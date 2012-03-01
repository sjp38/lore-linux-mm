Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 43F1A6B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 08:40:34 -0500 (EST)
Date: Thu, 1 Mar 2012 21:35:20 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH v2 5/9] writeback: introduce the pageout work
Message-ID: <20120301133520.GA7202@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.198713792@intel.com>
 <20120229135156.GA31106@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120229135156.GA31106@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> However the other type of works, if ever they come, can still block us
> for long time. Will need a proper way to guarantee fairness.

The simplistic way around this may be to refuse to queue new pageout
works when found other type of works in the queue. Then vmscan will
fall back to pageout(). It's rare condition anyway and hardly deserves
a comprehensive fairness scheme.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
