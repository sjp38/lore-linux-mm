Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 22C136B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 03:17:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 62B783EE0C1
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:17:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B41E45DEB7
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:17:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31B7B45DEB2
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:17:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 234721DB803E
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:17:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF2301DB8038
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 16:17:29 +0900 (JST)
Message-ID: <5159346B.1000000@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 16:16:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/28] super: fix calculation of shrinkable objects
 for small numbers
References: <1364548450-28254-1-git-send-email-glommer@parallels.com> <1364548450-28254-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-2-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Theodore Ts'o <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>

(2013/03/29 18:13), Glauber Costa wrote:
> The sysctl knob sysctl_vfs_cache_pressure is used to determine which
> percentage of the shrinkable objects in our cache we should actively try
> to shrink.
> 
> It works great in situations in which we have many objects (at least
> more than 100), because the aproximation errors will be negligible. But
> if this is not the case, specially when total_objects < 100, we may end
> up concluding that we have no objects at all (total / 100 = 0,  if total
> < 100).
> 
> This is certainly not the biggest killer in the world, but may matter in
> very low kernel memory situations.
> 
> [ v2: fix it for all occurrences of sysctl_vfs_cache_pressure ]
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
> CC: Dave Chinner <david@fromorbit.com>
> CC: "Theodore Ts'o" <tytso@mit.edu>
> CC: Al Viro <viro@zeniv.linux.org.uk>

I think reasonable.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
