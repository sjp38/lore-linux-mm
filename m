Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E813890013D
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 05:22:36 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 32F533EE0B6
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 18:22:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1715D45DEB4
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 18:22:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F1E4845DEB3
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 18:22:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E34FC1DB803B
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 18:22:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B02941DB8037
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 18:22:32 +0900 (JST)
Date: Tue, 23 Aug 2011 18:15:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom: skip frozen tasks
Message-Id: <20110823181505.f7dd43ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110823073101.6426.77745.stgit@zurg>
References: <20110823073101.6426.77745.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, 23 Aug 2011 11:31:01 +0300
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> All frozen tasks are unkillable, and if one of them has TIF_MEMDIE
> we must kill something else to avoid deadlock. After this patch
> select_bad_process() will skip frozen task before checking TIF_MEMDIE.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
