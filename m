Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3628E6B00FB
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 02:44:35 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D6iW37015366
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Oct 2010 15:44:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 735A245DE4D
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:44:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E3F945DE60
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:44:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 349E5EF8003
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:44:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8A3F1DB803B
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 15:44:31 +0900 (JST)
Date: Wed, 13 Oct 2010 15:39:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/3] mm, mem-hotplug: recalculate lowmem_reserve
 when memory hotplug occur
Message-Id: <20101013153909.316a4020.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101013152713.ADC0.A69D9226@jp.fujitsu.com>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com>
	<20101013151723.ADBD.A69D9226@jp.fujitsu.com>
	<20101013152713.ADC0.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Oct 2010 15:27:12 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Currently, memory hotplu call setup_per_zone_wmarks() and
> calculate_zone_inactive_ratio(), but don't call setup_per_zone_lowmem_reserve.
> 
> It mean number of reserved pages aren't updated even if memory hot plug
> occur. This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
