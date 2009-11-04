Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C2C036B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:39:40 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA40dcuG008471
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 09:39:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA0AB45DE4F
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:39:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8901245DE4D
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:39:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D10C01DB8037
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:39:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 67F0F1DB803F
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:39:34 +0900 (JST)
Date: Wed, 4 Nov 2009 09:36:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: RFC: Transparent Hugepage support
Message-Id: <20091104093659.5de0e49d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091103105543.GH11981@random.random>
References: <20091026185130.GC4868@random.random>
	<87ljiwk8el.fsf@basil.nowhere.org>
	<20091027193007.GA6043@random.random>
	<20091028042805.GJ7744@basil.fritz.box>
	<20091029094344.GA1068@elte.hu>
	<20091029103658.GJ9640@random.random>
	<20091030094037.9e0118d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20091103105543.GH11981@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 11:55:43 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Fri, Oct 30, 2009 at 09:40:37AM +0900, KAMEZAWA Hiroyuki wrote:
> > Ah, please keep CONFIG_TRANSPARENT_HUGEPAGE for a while.
> > Now, memcg don't handle hugetlbfs because it's special and cannot be freed by
> > the kernel, only users can free it. But this new transparent-hugepage seems to
> > be designed as that the kernel can free it for memory reclaiming.
> > So, I'd like to handle this in memcg transparently.
> > 
> > But it seems I need several changes to support this new rule.
> > I'm glad if this new huge page depends on !CONFIG_CGROUP_MEM_RES_CTRL for a
> > while.
> 
> Yeah the accounting (not just memcg) should be checked.. I didn't pay
> too much attention to stats at this point.
> 
> But we want to fix it fast instead of making the two options mutually
> exclusive.. Where are the pages de-accounted when they are freed?

It's de-accounted at page_remove_rmap() in typical case of Anon.
But swap-cache/bacthed-uncarhge related part is complicated, maybe.
...because of me ;(

Okay, I don't request !CONFIG_CGROUP_MEM_RES_CTRL, I'm glad if you CC me.

> Accounting seems to require just two one liners
> calling mem_cgroup_newpage_charge.
Yes, maybe so.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
