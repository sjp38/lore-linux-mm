Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 89C156B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 12:14:48 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so9049414pab.36
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 09:14:48 -0700 (PDT)
Message-ID: <52542F53.4020807@sr71.net>
Date: Tue, 08 Oct 2013 09:14:11 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] vmsplice: unmap gifted pages for recipient
References: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com> <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com>
In-Reply-To: <1381177293-27125-2-git-send-email-rcj@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert C Jennings <rcj@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/07/2013 01:21 PM, Robert C Jennings wrote:
> +					} else {
> +						if (vma)
> +							zap_page_range(vma,
> +								user_start,
> +								(user_end -
> +								 user_start),
> +								NULL);
> +						vma = find_vma_intersection(
> +								current->mm,
> +								useraddr,
> +								(useraddr +
> +								 PAGE_SIZE));
> +						if (!IS_ERR_OR_NULL(vma)) {
> +							user_start = useraddr;
> +							user_end = (useraddr +
> +								    PAGE_SIZE);
> +						} else
> +							vma = NULL;
> +					}

This is pretty unspeakably hideous.  Was there truly no better way to do
this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
