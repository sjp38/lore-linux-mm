Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACA16B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 11:00:58 -0400 (EDT)
Date: Tue, 6 Apr 2010 16:00:36 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/14] Memory Compaction v7
Message-ID: <20100406150036.GF17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <201004061747.16886.tarkan.erimer@turknet.net.tr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <201004061747.16886.tarkan.erimer@turknet.net.tr>
Sender: owner-linux-mm@kvack.org
To: Tarkan Erimer <tarkan.erimer@turknet.net.tr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:47:16PM +0300, Tarkan Erimer wrote:
> On Friday 02 April 2010 07:02:34 pm Mel Gorman wrote:
> > The only change is relatively minor and is around the migration of unmapped
> > PageSwapCache pages. Specifically, it's not safe to access anon_vma for
> > these pages when remapping after migration completes so the last patch
> > makes sure we don't.
> > 
> > Are there any further obstacles to merging?
> > 
> 
> These patches are applicable to which kernel version or versions ?
> I tried on 2.6.33.2 and 2.6.34-rc3 without succeed. 
> 

It's based on Andrew's tree mmotm-2010-03-24-14-48.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
