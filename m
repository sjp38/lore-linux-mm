Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 576976B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:52:23 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 14 Jun 2012 01:52:22 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5A8CE19D804E
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 07:52:17 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5E7qIKH176656
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 01:52:18 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5E7qIIs014846
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 01:52:18 -0600
Date: Thu, 14 Jun 2012 15:52:16 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/buddy: make skip_free_areas_node static
Message-ID: <20120614075216.GA29178@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1339656837-28941-1-git-send-email-shangw@linux.vnet.ibm.com>
 <4FD98E78.1060405@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FD98E78.1060405@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

>> Currently, function skip_free_areas_node() seems to be used only
>> by page allocator, so make it into static one.
>> 
>
>
>barrios@bbox:~/linux-next$ grep -nRH 'skip_free_areas_node' arch/ia64/
>arch/ia64/mm/discontig.c:633:		if (skip_free_areas_node(filter, nid))
>arch/ia64/mm/contig.c:56:		if (skip_free_areas_node(filter, nid))
>

Thanks for pointing it out, Minchan.

Thanks,
Gavin

>-- 
>Kind regards,
>Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
