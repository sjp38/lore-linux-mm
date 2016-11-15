Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 289616B02C4
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:10:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m203so9627052wma.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:10:05 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id c62si4638132wmc.109.2016.11.15.14.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:10:04 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id a20so4696845wme.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:10:03 -0800 (PST)
Date: Wed, 16 Nov 2016 01:10:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 05/21] mm: Trim __do_fault() arguments
Message-ID: <20161115221001.GE23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-6-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-6-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:01AM +0100, Jan Kara wrote:
>  static int do_cow_fault(struct vm_fault *vmf)
>  {
>  	struct vm_area_struct *vma = vmf->vma;
> -	struct page *fault_page, *new_page;
> -	void *fault_entry;
> +	struct page *new_page;

Why not get rid of new_page too?

Otherwise makes sense:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
