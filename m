Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 78E866B0083
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 14:01:55 -0500 (EST)
Message-ID: <4F4D2459.3010908@parallels.com>
Date: Tue, 28 Feb 2012 16:00:41 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/10] memcg: Uncharge all kmem when deleting a cgroup.
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org> <1330383533-20711-3-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1330383533-20711-3-git-send-email-ssouhlal@FreeBSD.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On 02/27/2012 07:58 PM, Suleiman Souhlal wrote:
> A later patch will also use this to move the accounting to the root
> cgroup.
>

Suleiman,

Did you do any measurements to figure out how long does it take, 
average, for dangling caches to go away ? Under memory pressure, let's say

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
