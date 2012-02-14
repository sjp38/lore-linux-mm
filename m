Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 620F36B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:34:26 -0500 (EST)
Date: Tue, 14 Feb 2012 12:34:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
Message-Id: <20120214123424.a4162251.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1202141354130.25634@router.home>
References: <bug-42578-27@https.bugzilla.kernel.org/>
	<201201180922.q0I9MCYl032623@bugzilla.kernel.org>
	<20120119122448.1cce6e76.akpm@linux-foundation.org>
	<20120210163748.GR5796@csn.ul.ie>
	<4F36DD77.1080306@ntlworld.com>
	<20120214130955.GM17917@csn.ul.ie>
	<alpine.DEB.2.00.1202141354130.25634@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Stuart Foster <smf.linux@ntlworld.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 14 Feb 2012 14:00:47 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 14 Feb 2012, Mel Gorman wrote:
> 
> > Thanks Stuart. Rik, Andrew, should the following be improved in some
> > way? I did not come to any decent conclusion on what to do with pages in
> > the inactive list with buffer_head as we are already stripping them when
> > the pages reach the end of the LRU.
> 
> We have made the statement in the past that configurations > 8GB on 32
> bit should not be considered stable or supported? The fact is the more
> memory you add on 32 bit the less low mem memory is available and the more
> likely that an OOM will occur for any number of reasons.

I have memories of 16G being usable in earlier kernels.

Also, if an 8G machine works OK at present, it's only by luck. 
sizeof(buffer_head) is around 100, so it takes 1.6GB of buffer_heads to
support 8G of 512-byte blocksize pagecache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
