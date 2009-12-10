Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 53DAA6B0078
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 12:38:29 -0500 (EST)
Date: Thu, 10 Dec 2009 18:38:19 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-ID: <20091210173819.GA5256@elte.hu>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210075454.GB25549@elte.hu>
 <20091210172040.37d259d3.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210083310.GB6834@elte.hu>
 <alpine.DEB.2.00.0912101134220.5481@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912101134220.5481@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 10 Dec 2009, Ingo Molnar wrote:
> 
> >
> > No, i'm not suggesting that - i'm just suggesting that right now MM
> > stats are not very well suited to be exposed via perf. If we wanted to
> > measure/sample the information in /proc/<pid>/statm it just wouldnt be
> > possible. We have a few events like pagefaults and a few tracepoints as
> > well - but more would be possible IMO.
> 
> vital MM stats are exposed via /proc/<pid> interfaces. Performance 
> monitoring is something optional MM VM stats are used for VM decision 
> on memory and process handling.

You list a few facts here but what is your point?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
