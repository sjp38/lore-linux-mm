Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 03FBC6B00E8
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 19:29:05 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8F3363EE0AE
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:29:04 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 774C545DEB4
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:29:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60EE545DE9E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:29:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51EF61DB803B
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:29:04 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AAD91DB803F
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 09:29:04 +0900 (JST)
Date: Mon, 5 Mar 2012 09:27:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/7 v2] mm: rework __isolate_lru_page() file/anon filter
Message-Id: <20120305092733.78d4f433.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120303091327.17599.80336.stgit@zurg>
References: <20120229091547.29236.28230.stgit@zurg>
	<20120303091327.17599.80336.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 03 Mar 2012 13:16:48 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This patch adds file/anon filter bits into isolate_mode_t,
> this allows to simplify checks in __isolate_lru_page().
> 
> v2:
> * use switch () instead of if ()
> * fixed lumpy-reclaim isolation mode
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

seems simple.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
