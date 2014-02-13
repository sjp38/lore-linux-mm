Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id D27C46B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 15:32:26 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id e9so19062705qcy.29
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 12:32:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d67si2086883qgf.75.2014.02.13.12.32.26
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 12:32:26 -0800 (PST)
Date: Thu, 13 Feb 2014 15:32:17 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <52fd2bda.496a8c0a.a4bd.ffffbbbaSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <52FC22E6.9010300@huawei.com>
References: <52FC22E6.9010300@huawei.com>
Subject: Re: [request for stable inclusion] mm/memory-failure.c: fix memory
 leak in successful soft offlining
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kirill.shutemov@linux.intel.com, hughd@google.com, Linux MM <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

Hello Xishi,

On Thu, Feb 13, 2014 at 09:41:58AM +0800, Xishi Qiu wrote:
> Hi Naoya or Greg,
> 
> f15bdfa802bfa5eb6b4b5a241b97ec9fa1204a35
> mm/memory-failure.c: fix memory leak in successful soft offlining
> 
> This patche look applicable to stable-3.10.
> After a successful page migration by soft offlining, the source 
> page is not properly freed and it's never reusable even if we 
> unpoison it afterward. This is caused by the race between freeing 
> page and setting PG_hwpoison.
> It was built successful for me. What do you think?

I agree to sending this patch into the stable.
I should've added "cc: stable" tag in patch description.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
