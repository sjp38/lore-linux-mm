Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 715016B0037
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:18:23 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so15859969pbc.19
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:18:23 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tr4si46490852pab.5.2014.01.03.10.18.21
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:18:22 -0800 (PST)
Message-ID: <52C6FED2.7070700@intel.com>
Date: Fri, 03 Jan 2014 10:17:54 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
References: <20140101002935.GA15683@localhost.localdomain> <52C5AA61.8060701@intel.com> <20140103033303.GB4106@localhost.localdomain>
In-Reply-To: <20140103033303.GB4106@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On 01/02/2014 07:33 PM, Han Pingtian wrote:
> @@ -130,8 +130,11 @@ static int set_recommended_min_free_kbytes(void)
>  			      (unsigned long) nr_free_buffer_pages() / 20);
>  	recommended_min <<= (PAGE_SHIFT-10);
>  
> -	if (recommended_min > min_free_kbytes)
> +	if (recommended_min > min_free_kbytes) {
> +		pr_info("raising min_free_kbytes from %d to %d to help transparent hugepage allocations\n",
> +			min_free_kbytes, recommended_min);
>  		min_free_kbytes = recommended_min;
> +	}
>  	setup_per_zone_wmarks();
>  	return 0;
>  }

I know I gave you that big bloated string, but 108 columns is a _wee_
bit over 80. :)

Otherwise, I do like the new message

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
