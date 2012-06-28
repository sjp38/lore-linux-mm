Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D39D06B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:58:37 -0400 (EDT)
Message-ID: <4FEBAC42.3030800@kernel.org>
Date: Thu, 28 Jun 2012 09:58:42 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: excessive CPU utilization by isolate_freepages?
References: <4FEB8237.6030402@sandia.gov> <4FEB9E73.5040709@kernel.org> <4FEBA520.4030205@redhat.com> <alpine.DEB.2.00.1206271745170.9552@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206271745170.9552@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Jim Schutt <jaschut@sandia.gov>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On 06/28/2012 09:52 AM, David Rientjes wrote:

> On Wed, 27 Jun 2012, Rik van Riel wrote:
> 
>>> > > I doubt compaction try to migrate continuously although we have no free
>>> > > memory.
>>> > > Could you apply this patch and retest?
>>> > > 
>>> > > https://lkml.org/lkml/2012/6/21/30
>> > 
> Not sure if Jim is using memcg; if not, then this won't be helpful.
> 


It doesn't related to memcg.
if compaction_alloc can't find suitable migration target, it returns NULL.
Then, migrate_pages should be exit.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
