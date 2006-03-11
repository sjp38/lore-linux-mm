Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
From: Peter Zijlstra <peter@programming.kicks-ass.net>
In-Reply-To: <aec7e5c30603100538v4942f9dbnfcc962f1a5bde190@mail.gmail.com>
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <1141993351.8165.10.camel@twins>
	 <aec7e5c30603100538v4942f9dbnfcc962f1a5bde190@mail.gmail.com>
Content-Type: text/plain
Date: Sat, 11 Mar 2006 22:08:15 +0100
Message-Id: <1142111295.2928.14.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2006-03-10 at 14:38 +0100, Magnus Damm wrote:
> On 3/10/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > Breaking the LRU in two like this breaks the page ordering, which makes
> > it possible for pages to stay resident even though they have much less
> > activity than pages that do get reclaimed.
> 
> Yes, true. But this happens already with a per-zone LRU. LRU pages
> that happen to end up in the DMA zone will probably stay there a
> longer time than pages in the normal zone. That does not mean it is
> right to break the page ordering though, I'm just saying it happens
> already and the oldest piece of data in the global system will not be
> reclaimed first - instead there are priorities such as unmapped pages
> will be reclaimed over mapped and so on. (I strongly feel that there
> should be per-node LRU:s, but that's another story)

If reclaim works right* there is equal pressure on each zone
(proportional to their size) and hence each page will have an equal life
time expectancy. 

(*) this is of course not possible for all workloads, however
balance_pgdat and the page allocator take pains to make it as true as
possible.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
