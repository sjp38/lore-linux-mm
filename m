Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E488C6B0073
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 21:01:39 -0400 (EDT)
Date: Tue, 11 Sep 2012 10:03:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] memory-hotplug: remove MIGRATE_ISOLATE from
 free_area->free_list
Message-ID: <20120911010336.GC14205@bbox>
References: <1346830033-32069-1-git-send-email-minchan@kernel.org>
 <xa1t1uigpefc.fsf@mina86.com>
 <20120906020850.GA31615@bbox>
 <xa1tipbr9uie.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xa1tipbr9uie.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Hi Michal,

On Thu, Sep 06, 2012 at 02:59:53PM +0200, Michal Nazarewicz wrote:
> > On Wed, Sep 05, 2012 at 07:28:23PM +0200, Michal Nazarewicz wrote:
> >> If you ask me, I'm not convinced that this improves anything.
> 
> On Thu, Sep 06 2012, Minchan Kim wrote:
> > At least, it removes MIGRATE_ISOLATE type in free_area->free_list
> > which is very irony type as I mentioned. I really don't like such
> > type in free_area. What's the benefit if we remain code as it is?
> > It could make more problem in future.
> 
> I don't really see current situation as making more problems in the
> future compared to this code.
> 
> You are introducing a new state for a page (ie. it's not in buddy, but
> in some new limbo state) and add a bunch of new code and thus bunch of
> new  bugs.  I don't see how this improves things over having generic
> code that handles moving pages between free lists.
> 
> PS.  free_list does exactly what it says on the tin -> the pages are
> free, ie. unallocated.  It does not say that they can be allocated. ;)

I saw two bug report about MIGRATE_ISOALTE type and NR_FREE_PAGES accounting
mistmatch problem until now and I think we can meet more problems
in the near future without solving it.

Maybe, [1] would be a solution but I really don't like to add new branch
in hotpath, even MIGRATE_ISOLATE used very rarely.
so, my patch is inpired. If there is another good idea that avoid
new branch in hotpath and solve the fundamental problem, I will drop this
patch.

Thanks.

[1] http://permalink.gmane.org/gmane.linux.kernel.mm/85199.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
