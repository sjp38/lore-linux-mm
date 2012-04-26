Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 765246B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 14:15:47 -0400 (EDT)
Message-ID: <4F9990D9.10300@redhat.com>
Date: Thu, 26 Apr 2012 14:15:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm V3] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
References: <4F998FDE.5020104@redhat.com>
In-Reply-To: <4F998FDE.5020104@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/26/2012 02:11 PM, Larry Woodman wrote:

> This patch changes do_migrate_pages() to only preserve the relative
> layout inside the
> program if the number of NUMA nodes in the source and destination mask
> are the
> same. If the number is different, we do a much more efficient migration
> by not touching
> memory that is in an allowed node.
>
> This preserves the old behaviour for programs that want it, while
> allowing a userspace
> NUMA placement tool to use the new, faster migration. This improves
> performance in
> our tests by up to a factor of 7.

> Signed-off-by: Larry Woodman<lwoodman@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
