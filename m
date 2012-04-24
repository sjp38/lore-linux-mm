Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0D6D16B004A
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:08:27 -0400 (EDT)
Date: Tue, 24 Apr 2012 11:08:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
In-Reply-To: <4F96CDE1.5000909@redhat.com>
Message-ID: <alpine.DEB.2.00.1204241106240.26005@router.home>
References: <4F96CDE1.5000909@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Woodman <lwoodman@redhat.com>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Motohiro Kosaki <mkosaki@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 24 Apr 2012, Larry Woodman wrote:

> While moving tasks between cpusets we noticed some strange behavior.
> Specifically if the nodes of the destination
> cpuset are a subset of the nodes of the source cpuset do_migrate_pages() will
> move pages that are already on a node
> in the destination cpuset.  The reason for this is do_migrate_pages() does not
> check whether each node in the source
> nodemask is in the destination nodemask before calling migrate_to_node().  If
> we simply do this check and skip them
> when the source is in the destination moving we wont move nodes that dont need
> to be moved.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
