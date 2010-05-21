Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC0A46B01AF
	for <linux-mm@kvack.org>; Fri, 21 May 2010 12:00:28 -0400 (EDT)
Date: Fri, 21 May 2010 18:00:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: RFC: dirty_ratio back to 40%
Message-ID: <20100521160014.GC3412@quack.suse.cz>
References: <20100521083408.1E36.A69D9226@jp.fujitsu.com>
 <4BF5D875.3030900@acm.org>
 <20100521100943.1E4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100521100943.1E4D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Zan Lynx <zlynx@acm.org>, lwoodman@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Fri 21-05-10 10:11:59, KOSAKI Motohiro wrote:
> > > So, I'd prefer to restore the default rather than both Redhat and SUSE apply exactly
> > > same distro specific patch. because we can easily imazine other users will face the same
> > > issue in the future.
> > 
> > On desktop systems the low dirty limits help maintain interactive feel. 
> > Users expect applications that are saving data to be slow. They do not 
> > like it when every application in the system randomly comes to a halt 
> > because of one program stuffing data up to the dirty limit.
> 
> really?
> Do you mean our per-task dirty limit wouldn't works?
> 
> If so, I think we need fix it. IOW sane per-task dirty limitation seems
> independent issue from per-system dirty limit.
  Well, I don't know about any per-task dirty limits. What function
implements them? Any application that dirties a single page can be caught
and forced to call balance_dirty_pages() and do writeback.
  But generally what we observe on a desktop with lots of dirty memory is
that application needs to allocate memory (either private one or for page
cache) and that triggers direct reclaim so the allocation takes a long
time to finish and thus the application is sluggish...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
