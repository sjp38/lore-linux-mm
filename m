Date: Sat, 7 Jul 2007 07:44:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memory unplug v7 - introduction
Message-Id: <20070707074401.64a394f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070706153401.d1d6bf88.akpm@linux-foundation.org>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
	<20070706153401.d1d6bf88.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007 15:34:01 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 6 Jul 2007 18:19:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This is a memory unplug base patch set against 2.6.22-rc6-mm1.
> 
> Well I stuck these in -mm, but I don't know what they do.  An overall
> description of the design would make any review much more effective.
> 
Ah yes, I also wants more people's review.

> ie: what does it all do, and how does it do it?
> 
> Also a description of the test setup and the testing results would be
> useful.
> 
Okay.
I'll try following in the next week.
- "How-to-use and the whole design" to Documentaion/vm/memory-hotplug.txt 
- Add more comments on source code about details.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
