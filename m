Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 62EC46B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 06:33:04 -0400 (EDT)
Date: Tue, 19 May 2009 18:32:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/3] vmscan: merge duplicate code in
	shrink_active_list()
Message-ID: <20090519103253.GA2667@localhost>
References: <20090517022327.280096109@intel.com> <20090517022742.320921900@intel.com> <20090518091653.GB10439@localhost> <20090519024316.GA7562@localhost> <20090519101833.GA1872@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090519101833.GA1872@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 19, 2009 at 06:18:33PM +0800, Johannes Weiner wrote:
> On Tue, May 19, 2009 at 10:43:16AM +0800, Wu Fengguang wrote:
> > @@ -1283,6 +1319,7 @@ static void shrink_active_list(unsigned 
> >  			 * are ignored, since JVM can create lots of anon
> >  			 * VM_EXEC pages.
> >  			 */
> > +			if (page_cluster)
> >  			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
> >  				list_add(&page->lru, &l_active);
> >  				continue;
> 
> Huh, what's with that hunk?

Ah, sorry, that's a handy debugging knob ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
