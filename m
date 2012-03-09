Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 5CD506B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 11:08:19 -0500 (EST)
Message-ID: <1331309451.29445.42.camel@sauron.fi.intel.com>
Subject: Re: [PATCH 5/9] writeback: introduce the pageout work
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Fri, 09 Mar 2012 18:10:51 +0200
In-Reply-To: <20120309095135.GC21038@quack.suse.cz>
References: <20120228160403.9c9fa4dc.akpm@linux-foundation.org>
	 <20120301123640.GA30369@localhost> <20120301163837.GA13104@quack.suse.cz>
	 <20120302044858.GA14802@localhost> <20120302095910.GB1744@quack.suse.cz>
	 <20120302103951.GA13378@localhost>
	 <20120302115700.7d970497.akpm@linux-foundation.org>
	 <20120303135558.GA9869@localhost>
	 <1331135301.32316.29.camel@sauron.fi.intel.com>
	 <20120309073113.GA5337@localhost> <20120309095135.GC21038@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Adrian Hunter <adrian.hunter@intel.com>

On Fri, 2012-03-09 at 10:51 +0100, Jan Kara wrote:
> > However I cannot find any ubifs functions to form the above loop, so
> > ubifs should be safe for now.
>   Yeah, me neither but I also failed to find a place where
> ubifs_evict_inode() truncates inode space when deleting the inode... Artem?

We do call 'truncate_inode_pages()':

static void ubifs_evict_inode(struct inode *inode)
{
	...

        truncate_inode_pages(&inode->i_data, 0);

        ...
}

-- 
Best Regards,
Artem Bityutskiy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
