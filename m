Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 19D0C6B0106
	for <linux-mm@kvack.org>; Thu, 11 Mar 2010 19:07:19 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2C077Uf013986
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Mar 2010 09:07:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A0B545DE7D
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 09:07:07 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B01FE45DE6E
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 09:07:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 449811DB803A
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 09:07:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D204AE18002
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 09:07:05 +0900 (JST)
Date: Fri, 12 Mar 2010 09:03:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Message-Id: <20100312090326.ad07c05c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100311235922.GA4569@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311180753.GE29246@redhat.com>
	<20100311235922.GA4569@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 00:59:22 +0100
Andrea Righi <arighi@develer.com> wrote:

> On Thu, Mar 11, 2010 at 01:07:53PM -0500, Vivek Goyal wrote:
> > On Wed, Mar 10, 2010 at 12:00:31AM +0100, Andrea Righi wrote:

> mmmh.. strange, on my side I get something as expected:
> 
> <root cgroup>
> $ dd if=/dev/zero of=test bs=1M count=500
> 500+0 records in
> 500+0 records out
> 524288000 bytes (524 MB) copied, 6.28377 s, 83.4 MB/s
> 
> <child cgroup with 100M memory.limit_in_bytes>
> $ dd if=/dev/zero of=test bs=1M count=500
> 500+0 records in
> 500+0 records out
> 524288000 bytes (524 MB) copied, 11.8884 s, 44.1 MB/s
> 
> Did you change the global /proc/sys/vm/dirty_* or memcg dirty
> parameters?
> 
what happens when bs=4k count=1000000 under 100M ? no changes ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
