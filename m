Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C7A4F6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 21:46:21 -0400 (EDT)
Message-ID: <4F98A90C.9020705@kernel.org>
Date: Thu, 26 Apr 2012 10:46:52 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] zsmalloc: rename zspage_order with zspage_pages
References: <1335334994-22138-1-git-send-email-minchan@kernel.org> <1335334994-22138-4-git-send-email-minchan@kernel.org> <4F97F634.1010400@vflare.org>
In-Reply-To: <4F97F634.1010400@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/25/2012 10:03 PM, Nitin Gupta wrote:

> On 04/25/2012 02:23 AM, Minchan Kim wrote:
> 
>> zspage_order defines how many pages are needed to make a zspage.
>> So _order_ is rather awkward naming. It already deceive Jonathan
>> - http://lwn.net/Articles/477067/
>> " For each size, the code calculates an optimum number of pages (up to 16)"
>>
>> Let's change from _order_ to _pages_.
>>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>> ---
>>  drivers/staging/zsmalloc/zsmalloc-main.c |   14 +++++++-------
>>  drivers/staging/zsmalloc/zsmalloc_int.h  |    2 +-
>>  2 files changed, 8 insertions(+), 8 deletions(-)
>>
> 
> 
> Recently, Seth changed max_zspage_order to ZS_MAX_PAGES_PER_ZSPAGE for
> the same reason. I think it would be better to rename the function in a
> similary way to have some consistency. So, we could use:
> 
> 1) get_pages_per_zspage() instead of get_zspage_pages()
> 2) class->pages_per_zspage instead of class->zspage_pages
> 


No problem. Will do.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
