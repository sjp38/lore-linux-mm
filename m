Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 066E36B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 02:18:58 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id l26so123813fgb.8
        for <linux-mm@kvack.org>; Sun, 11 Apr 2010 23:18:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100412060931.GP5683@laptop>
References: <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
	 <20100410184750.GJ5708@random.random> <20100410190233.GA30882@elte.hu>
	 <4BC0CFF4.5000207@redhat.com> <20100410194751.GA23751@elte.hu>
	 <4BC0DE84.3090305@redhat.com> <20100411104608.GA12828@elte.hu>
	 <4BC1B2CA.8050208@redhat.com> <20100411120800.GC10952@elte.hu>
	 <20100412060931.GP5683@laptop>
Date: Mon, 12 Apr 2010 09:18:56 +0300
Message-ID: <r2j84144f021004112318v78f28c3ds46531d1233966a20@mail.gmail.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 9:09 AM, Nick Piggin <npiggin@suse.de> wrote:
>> I think Andrea and Mel and you demonstrated that while defrag is futile in
>> theory (we can always fill up all of RAM with dentries and there's no 2MB
>> allocation possible), it seems rather usable in practice.
>
> One problem is that you need to keep a lot more memory free in order
> for it to be reasonably effective. Another thing is that the problem
> of fragmentation breakdown is not just a one-shot event that fills
> memory with pinned objects. It is a slow degredation.
>
> Especially when you use something like SLUB as the memory allocator
> which requires higher order allocations for objects which are pinned
> in kernel memory.

I guess we'd need to merge the SLUB defragmentation patches to fix that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
