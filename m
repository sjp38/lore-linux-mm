Date: Tue, 19 Jun 2007 12:20:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/7] Introduce a means of compacting memory within a zone
In-Reply-To: <20070619163611.GD17109@skynet.ie>
Message-ID: <Pine.LNX.4.64.0706191219250.7008@schroedinger.engr.sgi.com>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie>
 <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0706181010030.4751@schroedinger.engr.sgi.com>
 <20070619163611.GD17109@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Jun 2007, Mel Gorman wrote:

> When other mechanisms exist, they would be added here. Right now,
> isolate_lru_page() is the only one I am aware of.

Did you have a look at kmem_cache_vacate in the slab defrag patchset?

> > You do not need to check the result of migration? Page migration is a best 
> > effort that may fail.

> You're right. I used to check it for debugging purposes to make sure migration
> was actually occuring. It is not unusual still for a fair number of pages
> to fail to migrate. migration already uses a retry logic and I shouldn't
> be replicating it.
> 
> More importantly, by leaving the pages on the migratelist, I potentially
> retry the same migrations over and over again wasting time and effort not
> to mention that I keep pages isolated for much longer than necessary and
> that could cause stalling problems. I should be calling putback_lru_pages()
> when migrate_pages() tells me it failed to migrate pages.

No the putback_lru is done for you.
 
> I'll revisit this one. Thanks

You could simply ignore it if you do not care if its migrated or not.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
