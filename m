Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 0F5366B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 19:16:35 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 898F13EE0BC
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:16:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C2F445DEAD
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:16:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 518DA45DE7E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:16:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 39B101DB803E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:16:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4BAA1DB8038
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:16:32 +0900 (JST)
Date: Thu, 16 Feb 2012 09:15:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] memcg: use vm_swappiness from current memcg
Message-Id: <20120216091511.350882a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120215162834.13902.37262.stgit@zurg>
References: <20120215162830.13902.60256.stgit@zurg>
	<20120215162834.13902.37262.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 15 Feb 2012 20:28:34 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> At this point this is always the same cgroup, but it allows to drop one argument.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Do you mean "no logic change but clean up, dropping an argument" ?

I'm not sure using complicated sc-> is easier than passing an argument..

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
