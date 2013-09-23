Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 60EBE6B0031
	for <linux-mm@kvack.org>; Sun, 22 Sep 2013 22:06:55 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so2616245pbb.10
        for <linux-mm@kvack.org>; Sun, 22 Sep 2013 19:06:55 -0700 (PDT)
Message-ID: <523FA230.3020902@oracle.com>
Date: Mon, 23 Sep 2013 10:06:40 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] mm/zswap: avoid unnecessary page scanning
References: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com> <20130909162909.GB4701@variantweb.net>
In-Reply-To: <20130909162909.GB4701@variantweb.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On 09/10/2013 12:29 AM, Seth Jennings wrote:
> On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
>> add SetPageReclaim before __swap_writepage so that page can be moved to the
>> tail of the inactive list, which can avoid unnecessary page scanning as this
>> page was reclaimed by swap subsystem before.
>>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> 
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> 

Below is a reply from Mel in original thread "[PATCHv11 3/4] zswap: add
to mm/"
------------------
> +     /* start writeback */
> +     SetPageReclaim(page);
> +     __swap_writepage(page, &wbc, end_swap_bio_write);
> +     page_cache_release(page);
> +     zswap_written_back_pages++;
> +

SetPageReclaim? Why?. If the page is under writeback then why do you not
mark it as that? Do not free pages that are currently under writeback
obviously. It's likely that it was PageWriteback you wanted in zbud.c too.
--------------------

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
