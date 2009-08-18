Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7906B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 18:10:45 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7IM9YXU020466
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 18:09:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7IMAdEx178550
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 18:10:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7IM7k3K028915
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 18:07:46 -0400
Subject: Re: [PATCH 2/3]HTLB mapping for drivers. Hstate for files with
 hugetlb mapping(take 2)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.LFD.2.00.0908172333410.32114@casper.infradead.org>
References: <alpine.LFD.2.00.0908172333410.32114@casper.infradead.org>
Content-Type: text/plain
Date: Tue, 18 Aug 2009 15:10:38 -0700
Message-Id: <1250633438.7335.1146.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolev@infradead.org>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-08-17 at 23:40 +0100, Alexey Korolev wrote:
> 
> @@ -110,6 +111,10 @@ static inline void hugetlb_report_meminfo(struct
> seq_file *m)
>  #endif /* !CONFIG_HUGETLB_PAGE */
> 
>  #ifdef CONFIG_HUGETLBFS
> +
> +/* some random number */
> +#define HUGETLBFS_MAGIC        0x958458f6

Doesn't this belong in include/linux/magic.h?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
