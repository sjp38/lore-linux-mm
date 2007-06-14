Date: Fri, 15 Jun 2007 07:31:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070615073125.f5e4d6e2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46718320.1010500@csn.ul.ie>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
	<20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
	<20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
	<20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140706370.28544@schroedinger.engr.sgi.com>
	<20070615010217.62908da3.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140909030.29612@schroedinger.engr.sgi.com>
	<20070615011536.beaa79c1.kamezawa.hiroyu@jp.fujitsu.com>
	<46718320.1010500@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 19:04:16 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> >> That will retry the migration on the next pass. Add some concise comment 
> >> explaining the situation. This is general bug in page migration.
> >>
> > Ok, will do. thank you for your advice.
> > 
> 
> I am currently testing what I believe your patches currently look like.
> In combination with the isolate lru page fix patch, things are looking
> better than they were. Previously I had seen some very bizarre errors
> when migrating due to compaction of memory but I'm not seeing them now.
>  I hadn't been reporting because it was difficult to tell if migration
> was at fault or what memory compaction was doing.
> 
Thank you for reporting. I'm encouraged :)
I'll post updated version later. 

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
