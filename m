Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 17F446B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:24:09 -0400 (EDT)
Message-ID: <4F6B6DEA.3090408@redhat.com>
Date: Thu, 22 Mar 2012 14:22:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
References: <4F6B6BFF.1020701@redhat.com>
In-Reply-To: <4F6B6BFF.1020701@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lwoodman@redhat.com
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Motohiro Kosaki <mkosaki@redhat.com>

On 03/22/2012 02:14 PM, Larry Woodman wrote:

> With this change we only migrate from nodes that are not in the
> destination nodesets:

That's a pretty obvious improvement :)

> Migrating 7 to 4
> Migrating 6 to 3
> Migrating 5 to 4
> Migrating 2 to 3
> Migrating 1 to 4
> Migrating 0 to 3
>
> Signed-off-by: Larry Woodman<lwoodman@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
