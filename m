Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 592DD6B016D
	for <linux-mm@kvack.org>; Wed,  1 May 2013 04:08:23 -0400 (EDT)
Date: Wed, 1 May 2013 09:08:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/3] Obey mark_page_accessed hint given by filesystems
Message-ID: <20130501080819.GF11497@suse.de>
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
 <5180B601.8080005@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5180B601.8080005@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Wed, May 01, 2013 at 02:28:17PM +0800, Will Huck wrote:
> Hi Mel,
> On 04/30/2013 12:31 AM, Mel Gorman wrote:
> >Andrew Perepechko reported a problem whereby pages are being prematurely
> >evicted as the mark_page_accessed() hint is ignored for pages that are
> >currently on a pagevec -- http://www.spinics.net/lists/linux-ext4/msg37340.html .
> >Alexey Lyahkov and Robin Dong have also reported problems recently that
> >could be due to hot pages reaching the end of the inactive list too quickly
> >and be reclaimed.
> 
> Both shrink_active_list and shrink_inactive_list can call
> lru_add_drain(), why the hot pages can't be mark Actived during this
> time?
> 

Because by then it's not known that the filesystem had called
mark_page_accessed() to indicate the page should be activated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
