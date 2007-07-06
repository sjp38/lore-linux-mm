Date: Fri, 6 Jul 2007 15:40:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] memory unplug v7 - introduction
In-Reply-To: <20070706153401.d1d6bf88.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707061539330.26003@schroedinger.engr.sgi.com>
References: <20070706181903.428c3713.kamezawa.hiroyu@jp.fujitsu.com>
 <20070706153401.d1d6bf88.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, 6 Jul 2007, Andrew Morton wrote:

> On Fri, 6 Jul 2007 18:19:03 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This is a memory unplug base patch set against 2.6.22-rc6-mm1.
> 
> Well I stuck these in -mm, but I don't know what they do.  An overall
> description of the design would make any review much more effective.
> 
> ie: what does it all do, and how does it do it?

The two patches that you just merged and that I acked are also 
generally useful for page migration. They are also necessary for
Mel's memory compaction patchset. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
