Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C0A836B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 01:18:08 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI6I5xa018034
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 18 Dec 2009 15:18:06 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CB6B45DE4F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:18:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DB1445DE4C
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:18:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 60CF51DB803F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:18:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 150501DB803A
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:18:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
In-Reply-To: <20091218051210.GA417@elte.hu>
References: <alpine.DEB.2.00.0912171402550.4640@router.home> <20091218051210.GA417@elte.hu>
Message-Id: <20091218151342.653E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 18 Dec 2009 15:18:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

> 
> * Christoph Lameter <cl@linux-foundation.org> wrote:
> 
> > On Thu, 17 Dec 2009, Rik van Riel wrote:
> > 
> > > I believe it will be more useful if we figure out a way forward together.  
> > > Do you have any ideas on how to solve the hugepage swapping problem?
> > 
> > Frankly I am not sure that there is a problem. The word swap is mostly 
> > synonymous with "problem". Huge pages are good. I dont think one needs to 
> > necessarily associate something good (huge page) with a known problem (swap) 
> > otherwise the whole may not improve.
> 
> Swapping in the VM is 'reality', not some fringe feature. Almost every big 
> enterprise shop cares about it.
> 
> Note that it became more relevant in the past few years due to the arrival of 
> low-latency, lots-of-iops and cheap SSDs. Even on a low end server you can buy 
> a good 160 GB SSD for emergency swap with fantastic latency and for a lot less 
> money than 160 GB of real RAM. (which RAM wont even fit physically on typical 
> mainboards, is much more expensive and uses up more power and is less 
> servicable)

Agreed. This isn't artificial example. Recently I've heared some
major web service campany use case in japan. they use lots cheap
server (about $700 per server). then they said few memory and ssd
are good choice to them.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
