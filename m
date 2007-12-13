Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDJOXTk003878
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 14:24:33 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDJONBX209548
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:24:25 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDJON6e013878
	for <linux-mm@kvack.org>; Thu, 13 Dec 2007 12:24:23 -0700
Date: Thu, 13 Dec 2007 11:24:21 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 1/2] hugetlb: introduce nr_overcommit_hugepages
	sysctl
Message-ID: <20071213192421.GI17526@us.ibm.com>
References: <20071213074156.GA17526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213074156.GA17526@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com
Cc: wli@holomorphy.com, mel@csn.ul.ie, apw@shadowen.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.12.2007 [23:41:56 -0800], Nishanth Aravamudan wrote:
> hugetlb: introduce nr_overcommit_hugepages sysctl

<snip>

> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 8ac5171..b85a128 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -912,6 +912,14 @@ static struct ctl_table vm_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec,
>  	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "nr_overcommit_hugepages",
> +		.data		= &nr_overcommit_huge_pages,
> +		.maxlen		= sizeof(nr_overcommit_huge_pages),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_doulongvec_minmax,
> +	},

Dave's reply regarding the sysctl documentation, while unrelated to this
hunk, did remind me of something I wanted to ask. Having looked at
proc_doulongvec_minmax() a bit, it seems like I'm ok not specifying a
min and max, as the code checks to see if the min and max are specified.
Essentially, I want to allow any unsigned long value. Does this seem ok?
(there doesn't seem to be a proc_doulongvec() like there is
proc_dointvec().

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
