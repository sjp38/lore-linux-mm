Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id BBEFD6B0037
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 03:24:33 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so6781001pbc.2
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 00:24:33 -0800 (PST)
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com. [202.81.31.147])
        by mx.google.com with ESMTPS id r7si19642095pbk.117.2014.02.03.00.24.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Feb 2014 00:24:32 -0800 (PST)
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 3 Feb 2014 18:24:27 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BB2F03578052
	for <linux-mm@kvack.org>; Mon,  3 Feb 2014 19:24:21 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s138546o60162170
	for <linux-mm@kvack.org>; Mon, 3 Feb 2014 19:05:04 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s138OL4J008571
	for <linux-mm@kvack.org>; Mon, 3 Feb 2014 19:24:21 +1100
Message-ID: <52EF53B5.6050203@linux.vnet.ibm.com>
Date: Mon, 03 Feb 2014 14:00:45 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
References: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
In-Reply-To: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/22/2014 04:23 PM, Raghavendra K T wrote:
> max_sane_readahead returns zero on the cpu having no local memory
> node. Fix that by returning a sanitized number of pages viz.,
> minimum of (requested pages, 4k)
>
> Result:
> fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
> 32GB* 4G RAM  numa machine ( 12 iterations) yielded
>
> Kernel     Avg      Stddev
> base      7.2963    1.10 %
> patched   7.2972    1.18 %
>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---

Could you please let me know what do you feel about the patch ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
