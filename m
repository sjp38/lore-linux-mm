Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3729D8D004A
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:02:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DCDC23EE0AE
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:02:51 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C271C2AEB3F
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:02:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A817C2E6905
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:02:51 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CED9EF8001
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:02:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B5521DB8047
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:02:51 +0900 (JST)
Message-ID: <4DD30C9E.8010200@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:02:38 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 7/9] mm: proc: move show_numa_map() to fs/proc/task_mmu.c
References: <1305498029-11677-1-git-send-email-wilsons@start.ca> <1305498029-11677-8-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-8-git-send-email-wilsons@start.ca>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wilsons@start.ca
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, rientjes@google.com, lee.schermerhorn@hp.com, adobriyan@gmail.com, cl@linux-foundation.org

(2011/05/16 7:20), Stephen Wilson wrote:
> Moving show_numa_map() from mempolicy.c to task_mmu.c solves several
> issues.
> 
>    - Having the show() operation "miles away" from the corresponding
>      seq_file iteration operations is a maintenance burden.
> 
>    - The need to export ad hoc info like struct proc_maps_private is
>      eliminated.
> 
>    - The implementation of show_numa_map() can be improved in a simple
>      manner by cooperating with the other seq_file operations (start,
>      stop, etc) -- something that would be messy to do without this
>      change.
> 
> Signed-off-by: Stephen Wilson<wilsons@start.ca>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Hugh Dickins<hughd@google.com>
> Cc: David Rientjes<rientjes@google.com>
> Cc: Lee Schermerhorn<lee.schermerhorn@hp.com>
> Cc: Alexey Dobriyan<adobriyan@gmail.com>
> Cc: Christoph Lameter<cl@linux-foundation.org>

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
