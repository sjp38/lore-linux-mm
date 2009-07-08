Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C6C616B004D
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 11:18:32 -0400 (EDT)
Date: Wed, 8 Jul 2009 16:27:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Performance degradation seen after using one list for
	hot/coldpages.
Message-ID: <20090708152755.GC14601@csn.ul.ie>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20> <20090622165236.GE3981@csn.ul.ie> <20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com> <20090629091542.GC28597@csn.ul.ie> <98062A42B4E040F4861C78D172E2499B@sisodomain.com> <alpine.DEB.1.10.0907081051570.26162@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0907081051570.26162@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Narayanan Gopalakrishnan <narayanan.g@samsung.com>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Jul 08, 2009 at 10:53:38AM -0400, Christoph Lameter wrote:
> On Wed, 8 Jul 2009, Narayanan Gopalakrishnan wrote:
> 
> > We have done some stress testing using fsstress (LTP).
> > This patch seems to work fine with our OMAP based targets.
> > Can we have this merged?
> 
> Please post the patch that you tested. I am a bit confused due to
> topposting. There were several outstanding issues in the message you
> included.
> 

I know which patch he is on about, it's entitled "page-allocator: Preserve
PFN ordering when __GFP_COLD is set". There are a number of patches that
I don't believe have made it upstream or into mmotm but I've lost track
of what is in flight and what isn't. When an mmotm against 2.6.31-rc2 is
out, I'll be going through it again to see what made it in and resending
patches as appropriate.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
