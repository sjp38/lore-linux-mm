Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7220D6B01B4
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 22:31:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5S2Vr8C009778
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Jun 2010 11:31:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE67445DE4F
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:31:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E69A45DD77
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:31:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 831331DB803E
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:31:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2412A1DB803A
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 11:31:52 +0900 (JST)
Date: Mon, 28 Jun 2010 11:27:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [S+Q 05/16] SLUB: Constants need UL
Message-Id: <20100628112722.f2b09a07.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100625212104.072820103@quilx.com>
References: <20100625212026.810557229@quilx.com>
	<20100625212104.072820103@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Fri, 25 Jun 2010 16:20:31 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:

> UL suffix is missing in some constants. Conform to how slab.h uses constants.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
