Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AFC5C5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 21:37:13 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9M1bAvE006610
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 22 Oct 2010 10:37:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2238A45DE70
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:37:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F29F145DE6E
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:37:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4BC4EF8001
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:37:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A2C8EF8002
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 10:37:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: vmscan: Do not run shrinkers for zones other than ZONE_NORMAL
In-Reply-To: <alpine.DEB.2.00.1010211255570.24115@router.home>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
Message-Id: <20101022103620.53A9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 22 Oct 2010 10:37:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

I think this series has the same target with Nick's per-zone shrinker.
So, Do you dislike Nick's approach? can you please elaborate your intention?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
