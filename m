Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 79C4F6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 19:07:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 009443EE0BD
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:07:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC60345DEB2
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:07:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C25A545DEAD
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:07:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B00211DB8040
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:07:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BD9A1DB803E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:07:50 +0900 (JST)
Date: Thu, 16 Feb 2012 09:06:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: kill dead prev_priority stubs
Message-Id: <20120216090630.758a9258.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120215192708.31690.2819.stgit@zurg>
References: <20120215192708.31690.2819.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, 15 Feb 2012 23:27:08 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> This code was removed in v2.6.35-5854-g25edde0
> ("vmscan: kill prev_priority completely")
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
