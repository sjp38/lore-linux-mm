Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id DCF7B6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 21:01:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 42EC83EE0BD
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:01:43 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 24CAE45DEBC
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 022E345DE7E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E81681DB803E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:01:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AABFE08006
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:01:42 +0900 (JST)
Message-ID: <4F974C84.6010407@jp.fujitsu.com>
Date: Wed, 25 Apr 2012 09:59:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/23] memcg: Make it possible to use the stock for more
 than one page.
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1334959051-18203-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1334959051-18203-5-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Suleiman Souhlal <ssouhlal@FreeBSD.org>

(2012/04/21 6:57), Glauber Costa wrote:

> From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
> 
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>


ok, should work enough.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
