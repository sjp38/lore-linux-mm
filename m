Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8E0A06B00ED
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 18:05:36 -0500 (EST)
Message-ID: <4F4C0C40.5080604@xenotime.net>
Date: Mon, 27 Feb 2012 15:05:36 -0800
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] memcg: Document kernel memory accounting.
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org> <1330383533-20711-11-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1330383533-20711-11-git-send-email-ssouhlal@FreeBSD.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On 02/27/2012 02:58 PM, Suleiman Souhlal wrote:

> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> ---
>  Documentation/cgroups/memory.txt |   44 +++++++++++++++++++++++++++++++++++--
>  1 files changed, 41 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 4c95c00..64c6cc8 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt

> +2.7.1.1 Slab memory accounting
> +
> +Slab gets accounted on a per-page basis, which is done by using per-cgroup
> +kmem_caches. These per-cgroup kmem_caches get created on-demand, the first
> +time a specific kmem_cache gets used by a cgroup.
> +
> +Slab memory that cannot be attributed to a cgroup gets charged to the root
> +cgroup.
> +
> +A per-cgroup kmem_cache is named like the original, with the cgroup's name
> +in parethesis.


      parentheses.

> +
> +When a cgroup is destroyed, all its kmem_caches get migrated to the root
> +cgroup, and "dead" is appended to their name, to indicate that they are not
> +going to be used for new allocations.
> +These dead caches automatically get removed once there are no more active
> +slab objects in them.
> +

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
