Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 943926B0062
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:10:47 -0400 (EDT)
Message-ID: <4FD98E78.1060405@kernel.org>
Date: Thu, 14 Jun 2012 16:10:48 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/buddy: make skip_free_areas_node static
References: <1339656837-28941-1-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1339656837-28941-1-git-send-email-shangw@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On 06/14/2012 03:53 PM, Gavin Shan wrote:

> Currently, function skip_free_areas_node() seems to be used only
> by page allocator, so make it into static one.
> 


barrios@bbox:~/linux-next$ grep -nRH 'skip_free_areas_node' arch/ia64/
arch/ia64/mm/discontig.c:633:		if (skip_free_areas_node(filter, nid))
arch/ia64/mm/contig.c:56:		if (skip_free_areas_node(filter, nid))

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
