Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 647DE6B0098
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 21:22:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P1MsB2026489
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 25 Oct 2010 10:22:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A4E445DE55
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 10:22:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 68D6645DE51
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 10:22:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 320161DB8038
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 10:22:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9867DE18007
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 10:22:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <alpine.DEB.2.00.1010220859080.19498@router.home>
References: <20101022103620.53A9.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010220859080.19498@router.home>
Message-Id: <20101025101009.915D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Oct 2010 10:22:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 22 Oct 2010, KOSAKI Motohiro wrote:
> 
> > I think this series has the same target with Nick's per-zone shrinker.
> > So, Do you dislike Nick's approach? can you please elaborate your intention?
> 
> Sorry. I have not seen Nicks approach.
> 
> The per zone approach seems to be at variance with how objects are tracked
> at the slab layer. There is no per zone accounting there. So attempts to
> do expiration of caches etc at that layer would not work right.

Please define your 'right' behavior ;-)

If we need to discuss 'right' thing, we also need to define how behavior
is right, I think. slab API itself don't have zone taste. but it implictly 
depend on a zone because buddy and reclaim are constructed on zones and 
slab is constructed on buddy. IOW, every slab object have a home zone.

So, which workload or usecause make a your head pain?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
