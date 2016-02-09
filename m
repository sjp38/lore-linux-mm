Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id ACF6B6B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 16:20:13 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id q63so35214pfb.0
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 13:20:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a84si11854104pfj.109.2016.02.09.13.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 13:20:12 -0800 (PST)
Date: Tue, 9 Feb 2016 13:20:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp, vmstats: count deferred split events
Message-Id: <20160209132012.db18cdd7203b1d8b29483657@linux-foundation.org>
In-Reply-To: <1455009302-57702-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455009302-57702-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Tue,  9 Feb 2016 12:15:02 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Counts how many times we put a THP in split queue. Currently, it happens
> on partial unmap of a THP.

Why do we need this?

> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -847,6 +847,7 @@ const char * const vmstat_text[] = {
>  	"thp_collapse_alloc_failed",
>  	"thp_split_page",
>  	"thp_split_page_failed",
> +	"thp_deferred_split_page",
>  	"thp_split_pmd",
>  	"thp_zero_page_alloc",
>  	"thp_zero_page_alloc_failed",

Documentation/vm/transhuge.txt, please.  While you're in there please
check that we haven't missed anything else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
