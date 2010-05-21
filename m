Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B55826B01B4
	for <linux-mm@kvack.org>; Fri, 21 May 2010 11:51:13 -0400 (EDT)
Date: Fri, 21 May 2010 17:50:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: RFC: dirty_ratio back to 40%
Message-ID: <20100521155059.GB3412@quack.suse.cz>
References: <4BF51B0A.1050901@redhat.com>
 <20100521083408.1E36.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100521083408.1E36.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: lwoodman@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

  Hi,

On Fri 21-05-10 08:48:57, KOSAKI Motohiro wrote:
> CC to Nick and Jan
  Thanks.

> > We've seen multiple performance regressions linked to the lower(20%)
> > dirty_ratio.  When performing enough IO to overwhelm the background  
> > flush daemons the percent of dirty pagecache memory quickly climbs 
> > to the new/lower dirty_ratio value of 20%.  At that point all writing 
> > processes are forced to stop and write dirty pagecache pages back to disk.  
> > This causes performance regressions in several benchmarks as well as causing
> > a noticeable overall sluggishness.  We all know that the dirty_ratio is
> > an integrity vs performance trade-off but the file system journaling
> > will cover any devastating effects in the event of a system crash.
> > 
> > Increasing the dirty_ratio to 40% will regain the performance loss seen
> > in several benchmarks.  Whats everyone think about this???
> 
> In past, Jan Kara also claim the exactly same thing.
> 
> 	Subject: [LSF/VM TOPIC] Dynamic sizing of dirty_limit
> 	Date: Wed, 24 Feb 2010 15:34:42 +0100
> 
> 	> (*) We ended up increasing dirty_limit in SLES 11 to 40% as it used to be
> 	> with old kernels because customers running e.g. LDAP (using BerkelyDB
> 	> heavily) were complaining about performance problems.
> 
> So, I'd prefer to restore the default rather than both Redhat and SUSE apply exactly
> same distro specific patch. because we can easily imazine other users will face the same
> issue in the future.
> 
> 	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Nick, Jan, if the above is too old and your distro have been dropped the patch, please
> correct me.
  No, SLE11 SP1 still has a patch that increases dirty_ratio to 40. But on
the other hand I agree with Zan that for desktop, 40% of memory for dirty
data is a lot these days and takes a long time to write out (it could
easily be 30s - 1m). On a desktop the memory is much better used as
a read-only pagecache or for memory hungry apps like Firefox or Acrobat
Reader.  So I believe for a desktop the current setting (20) is a better
choice. So until we find a way how to dynamically size the dirty limit, we
have to decide whether we want to have a default setting for a server or
for a desktop... Personally, I don't care very much and I feel my time
would be better spent thinking about dynamic limit sizing rather than
arguing what is better default ;).

									Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
