Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id CA6446B0169
	for <linux-mm@kvack.org>; Wed,  1 May 2013 04:06:51 -0400 (EDT)
Date: Wed, 1 May 2013 09:06:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/3] mm: Ensure that mark_page_accessed moves pages to
 the active list
Message-ID: <20130501080644.GE11497@suse.de>
References: <1367253119-6461-1-git-send-email-mgorman@suse.de>
 <1367253119-6461-3-git-send-email-mgorman@suse.de>
 <5180AB0E.6030407@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5180AB0E.6030407@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ben <sam.bennn@gmail.com>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Wed, May 01, 2013 at 01:41:34PM +0800, Sam Ben wrote:
> Hi Mel,
> On 04/30/2013 12:31 AM, Mel Gorman wrote:
> >If a page is on a pagevec then it is !PageLRU and mark_page_accessed()
> >may fail to move a page to the active list as expected. Now that the
> >LRU is selected at LRU drain time, mark pages PageActive if they are
> >on a pagevec so it gets moved to the correct list at LRU drain time.
> >Using a debugging patch it was found that for a simple git checkout
> >based workload that pages were never added to the active file list in
> 
> Could you show us the details of your workload?
> 

The workload is git checkouts of a fixed number of commits for the
kernel git tree. It starts with a warm-up run that is not timed and then
records the time for a number of iterations.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
