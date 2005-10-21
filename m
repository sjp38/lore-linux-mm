Message-ID: <4358588D.1080307@jp.fujitsu.com>
Date: Fri, 21 Oct 2005 11:55:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> +	/* Is the user allowed to access the target nodes? */
> +	if (!nodes_subset(new, cpuset_mems_allowed(task)))
> +		return -EPERM;
> +
How about this ?
+cpuset_update_task_mems_allowed(task, new);    (this isn't implemented now)

> +	err = do_migrate_pages(mm, &old, &new, MPOL_MF_MOVE);
> +

or it's user's responsibility  to updates his mempolicy before
calling sys_migrage_pages() ?

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
