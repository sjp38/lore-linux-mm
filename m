Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 0738E6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 13:52:45 -0400 (EDT)
Message-ID: <4FDA24BA.7070306@redhat.com>
Date: Thu, 14 Jun 2012 13:51:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix page reclaim comment error
References: <1339677662-25942-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1339677662-25942-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, trivial@kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On 06/14/2012 08:41 AM, Wanpeng Li wrote:
> From: Wanpeng Li<liwp@linux.vnet.ibm.com>
>
> Since there are five lists in LRU cache, the array nr in get_scan_count
> should be:
>
> nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
> nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
>
> Signed-off-by: Wanpeng Li<liwp.linux@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
