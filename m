Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C707C8D003B
	for <linux-mm@kvack.org>; Tue, 17 May 2011 20:01:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0D21E3EE081
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:01:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E734C45DE58
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:01:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D02E545DE56
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:01:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C08BEE08001
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:01:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D0DF1DB8047
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:01:45 +0900 (JST)
Message-ID: <4DD30C4B.5060104@jp.fujitsu.com>
Date: Wed, 18 May 2011 09:01:15 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/9] mm: make gather_stats() type-safe and remove forward
 declaration
References: <1305498029-11677-1-git-send-email-wilsons@start.ca> <1305498029-11677-5-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-5-git-send-email-wilsons@start.ca>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wilsons@start.ca
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hughd@google.com, rientjes@google.com, lee.schermerhorn@hp.com, adobriyan@gmail.com, cl@linux-foundation.org

(2011/05/16 7:20), Stephen Wilson wrote:
> Improve the prototype of gather_stats() to take a struct numa_maps as
> argument instead of a generic void *.  Update all callers to make the
> required type explicit.
> 
> Since gather_stats() is not needed before its definition and is
> scheduled to be moved out of mempolicy.c the declaration is removed as
> well.
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
