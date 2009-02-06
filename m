Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0EC666B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:20:21 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n163KJR8011708
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 6 Feb 2009 12:20:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F01145DD7B
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:20:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0903445DD78
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:20:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9D181DB803E
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:20:18 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 90F9D1DB803C
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 12:20:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] swsusp: clean up shrink_all_zones()
In-Reply-To: <20090206031323.821014885@cmpxchg.org>
References: <20090206031125.693559239@cmpxchg.org> <20090206031323.821014885@cmpxchg.org>
Message-Id: <20090206121853.79C6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  6 Feb 2009 12:20:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Move local variables to innermost possible scopes and use local
> variables to cache calculations/reads done more than once.
> 
> No change in functionality (intended).
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c |   23 +++++++++++------------
>  1 file changed, 11 insertions(+), 12 deletions(-)

ok. good cleanup.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
