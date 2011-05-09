Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7C3F6B0024
	for <linux-mm@kvack.org>; Mon,  9 May 2011 03:45:43 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2438F3EE0C2
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:45:41 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07B3A45DE61
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:45:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E26A245DE6F
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:45:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D62D01DB802C
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:45:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E26D1DB803A
	for <linux-mm@kvack.org>; Mon,  9 May 2011 16:45:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] mm: make gather_stats() type-safe and remove forward declaration
In-Reply-To: <1303947349-3620-5-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca> <1303947349-3620-5-git-send-email-wilsons@start.ca>
Message-Id: <20110509164723.165B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  9 May 2011 16:45:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Improve the prototype of gather_stats() to take a struct numa_maps as
> argument instead of a generic void *.  Update all callers to make the
> required type explicit.
> 
> Since gather_stats() is not needed before its definition and is
> scheduled to be moved out of mempolicy.c the declaration is removed as
> well.
> 
> Signed-off-by: Stephen Wilson <wilsons@start.ca>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
