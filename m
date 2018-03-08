Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 472AD6B0009
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 17:27:02 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o23so4053028wrc.9
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:27:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c11si13351277wri.508.2018.03.08.14.27.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 14:27:01 -0800 (PST)
Date: Thu, 8 Mar 2018 14:26:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Message-Id: <20180308142658.285e0b2ab50b81449783cd4a@linux-foundation.org>
In-Reply-To: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
References: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: willy@infradead.org, linux-mm@kvack.org

On Thu, 8 Mar 2018 18:35:23 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:

> Use new return type vm_fault_t for fault handler
> in struct vm_operations_struct.

I can't find vm_fault_t?

> vmf_insert_mixed(), vmf_insert_pfn() and vmf_insert_page()
> are newly added inline wrapper functions.

Why?

> index ad06d42..a4d8853 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -379,17 +379,18 @@ struct vm_operations_struct {
>  	void (*close)(struct vm_area_struct * area);
>  	int (*split)(struct vm_area_struct * area, unsigned long addr);
>  	int (*mremap)(struct vm_area_struct * area);
> -	int (*fault)(struct vm_fault *vmf);
> -	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
> +	vm_fault_t (*fault)(struct vm_fault *vmf);
> +	vm_fault_t (*huge_fault)(struct vm_fault *vmf,
> +			enum page_entry_size pe_size);

Well if we're going to do this then we should convert all the
.page_mkwrite() instances and a bunch of other stuff to use vm_fault_t.
It's a lot of work.  Perhaps we should just keep using "int".
