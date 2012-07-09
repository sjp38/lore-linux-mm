Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9C0D96B0096
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 06:43:51 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so23090501pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 03:43:50 -0700 (PDT)
Date: Mon, 9 Jul 2012 03:43:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb: split out
 is_hugetlb_entry_migration_or_hwpoison
In-Reply-To: <1341828761-11195-1-git-send-email-liwp.linux@gmail.com>
Message-ID: <alpine.DEB.2.00.1207090343110.8224@chino.kir.corp.google.com>
References: <1341828761-11195-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 9 Jul 2012, Wanpeng Li wrote:

> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Code was duplicated in two functions, clean it up.
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>  mm/hugetlb.c |   20 +++++++++-----------
>  1 files changed, 9 insertions(+), 11 deletions(-)

Nack, this makes the code more convoluted then the hugetlb code already is 
and savings two lines of code isn't worth it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
