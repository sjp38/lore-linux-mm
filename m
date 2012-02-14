Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B95956B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:00:50 -0500 (EST)
Date: Tue, 14 Feb 2012 14:00:47 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
In-Reply-To: <20120214130955.GM17917@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1202141354130.25634@router.home>
References: <bug-42578-27@https.bugzilla.kernel.org/> <201201180922.q0I9MCYl032623@bugzilla.kernel.org> <20120119122448.1cce6e76.akpm@linux-foundation.org> <20120210163748.GR5796@csn.ul.ie> <4F36DD77.1080306@ntlworld.com> <20120214130955.GM17917@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Stuart Foster <smf.linux@ntlworld.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 14 Feb 2012, Mel Gorman wrote:

> Thanks Stuart. Rik, Andrew, should the following be improved in some
> way? I did not come to any decent conclusion on what to do with pages in
> the inactive list with buffer_head as we are already stripping them when
> the pages reach the end of the LRU.

We have made the statement in the past that configurations > 8GB on 32
bit should not be considered stable or supported? The fact is the more
memory you add on 32 bit the less low mem memory is available and the more
likely that an OOM will occur for any number of reasons.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
