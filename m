Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E63A86B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:57:02 -0500 (EST)
Date: Fri, 2 Mar 2012 11:57:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
Message-Id: <20120302115700.7d970497.akpm@linux-foundation.org>
In-Reply-To: <20120302103951.GA13378@localhost>
References: <20120228140022.614718843@intel.com>
	<20120228144747.198713792@intel.com>
	<20120228160403.9c9fa4dc.akpm@linux-foundation.org>
	<20120301123640.GA30369@localhost>
	<20120301163837.GA13104@quack.suse.cz>
	<20120302044858.GA14802@localhost>
	<20120302095910.GB1744@quack.suse.cz>
	<20120302103951.GA13378@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2 Mar 2012 18:39:51 +0800
Fengguang Wu <fengguang.wu@intel.com> wrote:

> > And I agree it's unlikely but given enough time and people, I
> > believe someone finds a way to (inadvertedly) trigger this.
> 
> Right. The pageout works could add lots more iput() to the flusher
> and turn some hidden statistical impossible bugs into real ones.
> 
> Fortunately the "flusher deadlocks itself" case is easy to detect and
> prevent as illustrated in another email.

It would be a heck of a lot safer and saner to avoid the iput().  We
know how to do this, so why not do it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
