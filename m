Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 1BDF26B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 00:33:51 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A6BE53EE0B6
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:33:49 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F11B45DEB2
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:33:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 79C7F45DE7E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:33:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 672D21DB803F
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:33:49 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E7CB1DB8038
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:33:49 +0900 (JST)
Date: Fri, 2 Mar 2012 14:32:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 7/7] mm/memcg: use vm_swappiness from target memory
 cgroup
Message-Id: <20120302143220.ac7fcc53.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120229091604.29236.63600.stgit@zurg>
References: <20120229090748.29236.35489.stgit@zurg>
	<20120229091604.29236.63600.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 29 Feb 2012 13:16:04 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> Use vm_swappiness from memory cgroup which is triggered this memory reclaim.
> This is more reasonable and allows to kill one argument.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

seems reasonable to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
