Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1MMK5Tf006896
	for <linux-mm@kvack.org>; Wed, 22 Feb 2006 17:20:05 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1MMK6Z0223068
	for <linux-mm@kvack.org>; Wed, 22 Feb 2006 17:20:06 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k1MMK6oJ006865
	for <linux-mm@kvack.org>; Wed, 22 Feb 2006 17:20:06 -0500
Message-ID: <43FCE394.9010502@austin.ibm.com>
Date: Wed, 22 Feb 2006 16:20:04 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][patch] mm: single pcp lists
References: <20060222143217.GI15546@wotan.suse.de>
In-Reply-To: <20060222143217.GI15546@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> -struct per_cpu_pages {
> +struct per_cpu_pageset {
> +	struct list_head list;	/* the list of pages */
>  	int count;		/* number of pages in the list */
> +	int cold_count;		/* number of cold pages in the list */
>  	int high;		/* high watermark, emptying needed */
>  	int batch;		/* chunk size for buddy add/remove */
> -	struct list_head list;	/* the list of pages */
> -};

Any particular reason to move the list_head to the front?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
