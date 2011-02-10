Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 896598D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 05:41:14 -0500 (EST)
Date: Thu, 10 Feb 2011 11:41:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] vmscan: fix zone shrinking exit when scan work is done
Message-ID: <20110210104111.GD26653@tiehlicka.suse.cz>
References: <20110209154606.GJ27110@cmpxchg.org>
 <20110209164656.GA1063@csn.ul.ie>
 <20110209182846.GN3347@random.random>
 <20110210102109.GB17873@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110210102109.GB17873@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 10-02-11 10:21:10, Mel Gorman wrote:
> On Wed, Feb 09, 2011 at 07:28:46PM +0100, Andrea Arcangeli wrote:
> > On Wed, Feb 09, 2011 at 04:46:56PM +0000, Mel Gorman wrote:
> > > On Wed, Feb 09, 2011 at 04:46:06PM +0100, Johannes Weiner wrote:
> > > > Hi,
> > > > 
> > > > I think this should fix the problem of processes getting stuck in
> > > > reclaim that has been reported several times.
> > > 
> > > I don't think it's the only source but I'm basing this on seeing
> > > constant looping in balance_pgdat() and calling congestion_wait() a few
> > > weeks ago that I haven't rechecked since. However, this looks like a
> > > real fix for a real problem.
> > 
> > Agreed. Just yesterday I spent some time on the lumpy compaction
> > changes after wondering about Michal's khugepaged 100% report, and I
> > expected some fix was needed in this area (as I couldn't find any bug
> > in khugepaged yet, so the lumpy compaction looked the next candidate
> > for bugs).
> > 
> 
> Michal did report that disabling defrag did not help but the stack trace
> also showed that it was stuck in shrink_zone() which is what Johannes'
> patch targets. It's not unreasonable to test if Johannes' patch solves
> Michal's problem. Michal, I know that your workload is a bit random and
> may not be reproducible but do you think it'd be possible to determine
> if Johannes' patch helps?

Sure, I can test it. Nevertheless, I haven't seen the problem again. I
have tried to make some memory pressure on the machine but no "luck".

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
