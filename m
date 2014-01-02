Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 995F76B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 13:05:29 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so14327454pde.41
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 10:05:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o7si32122581pbb.100.2014.01.02.10.05.27
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 10:05:28 -0800 (PST)
Message-ID: <52C5AA61.8060701@intel.com>
Date: Thu, 02 Jan 2014 10:05:21 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
References: <20140101002935.GA15683@localhost.localdomain>
In-Reply-To: <20140101002935.GA15683@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On 12/31/2013 04:29 PM, Han Pingtian wrote:
> min_free_kbytes may be updated during thp's initialization. Sometimes,
> this will change the value being set by user. Showing message will
> clarify this confusion.
...
> -	if (recommended_min > min_free_kbytes)
> +	if (recommended_min > min_free_kbytes) {
>  		min_free_kbytes = recommended_min;
> +		pr_info("min_free_kbytes is updated to %d by enabling transparent hugepage.\n",
> +			min_free_kbytes);
> +	}

"updated" doesn't tell us much.  It's also kinda nasty that if we enable
then disable THP, we end up with an elevated min_free_kbytes.  Maybe we
should at least put something in that tells the user how to get back
where they were if they care:

"raising min_free_kbytes from %d to %d to help transparent hugepage
allocations"


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
