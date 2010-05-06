Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 868E36B023F
	for <linux-mm@kvack.org>; Thu,  6 May 2010 02:23:06 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o466N3kE026493
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 May 2010 15:23:03 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CD07345DE59
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:23:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F9DC45DE61
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:23:02 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F1911DB803F
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:23:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E0B6D1DB8040
	for <linux-mm@kvack.org>; Thu,  6 May 2010 15:22:58 +0900 (JST)
Date: Thu, 6 May 2010 15:18:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] mm: memcontrol - uninitialised return value
Message-Id: <20100506151858.cf3a5fe7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
References: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Phil Carmody <ext-phil.2.carmody@nokia.com>
Cc: balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed,  5 May 2010 14:21:49 +0300
Phil Carmody <ext-phil.2.carmody@nokia.com> wrote:

> From: Phil Carmody <ext-phil.2.carmody@nokia.com>
> 
> Only an out of memory error will cause ret to be set.
> 
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
