Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0E4B36B02C7
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:50:14 -0400 (EDT)
Date: Fri, 20 Aug 2010 13:50:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100820055006.GA13916@localhost>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
 <20100819074602.GW19797@csn.ul.ie>
 <5EF4FA9117384B1A80228C96926B4125@rainbow>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5EF4FA9117384B1A80228C96926B4125@rainbow>
Sender: owner-linux-mm@kvack.org
To: Iram Shahzad <iram.shahzad@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 01:45:56PM +0800, Iram Shahzad wrote:
> > What is your test scenario? Who or what has these pages isolated that is
> > allowing too_many_isolated() to be true?
> 
> I have a test app that attempts to create fragmentation. Then I run
> echo 1 > /proc/sys/vm/compact_memory
> That is all.

That's all? Is you system idle otherwise? (for example, fresh booted
and not running many processes)

> The test app mallocs 2MB 100 times, memsets them.
> Then it frees the even numbered 2MB blocks.
> That is, 2MB*50 remains malloced and 2MB*50 gets freed.
 
We are interested in the test app, can you share it? :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
