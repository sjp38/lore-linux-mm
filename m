Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id A6C366B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 10:21:21 -0500 (EST)
Date: Tue, 28 Feb 2012 23:15:50 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/9] memcg: dirty page accounting support routines
Message-ID: <20120228151550.GA5490@localhost>
References: <20120228140022.614718843@intel.com>
 <20120228144747.124608935@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228144747.124608935@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 28, 2012 at 10:00:26PM +0800, Fengguang Wu wrote:
> From: Greg Thelen <gthelen@google.com>
> 
> Added memcg dirty page accounting support routines.  These routines are
> used by later changes to provide memcg aware writeback and dirty page
> limiting.  A mem_cgroup_dirty_info() tracepoint is is also included to
> allow for easier understanding of memcg writeback operation.

Greg, sorry that the mem_cgroup_dirty_info() interfaces and
tracepoints are abridged since they are not used here. Obviously this
patch series is not enough to keep the number of dirty pages under
control. It only tries to improve page reclaim behavior given whatever
dirty number. We'll need further schemes to keep dirty pages under
sane levels, so that unrelated tasks do not suffer from reclaim waits
when there are heavy writers in the same memcg.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
