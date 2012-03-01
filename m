Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 3514F6B007E
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 05:14:25 -0500 (EST)
Date: Thu, 1 Mar 2012 11:13:54 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/9] mm: dont set __GFP_WRITE on ramfs/sysfs writes
Message-ID: <20120301101354.GD1665@cmpxchg.org>
References: <20120228140022.614718843@intel.com>
 <20120228144747.440418051@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120228144747.440418051@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 28, 2012 at 10:00:30PM +0800, Fengguang Wu wrote:
> Try to avoid page reclaim waits when writing to ramfs/sysfs etc.
> 
> Maybe not a big deal...

This looks like a separate fix that would make sense standalone.  It's
not just the waits, there is not much of a point in skipping zones
during allocation based on the dirty usage which they'll never
contribute to.  Could you maybe pull this up front?

> CC: Johannes Weiner <jweiner@redhat.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
