Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 467908D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 13:17:56 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p23I53Lv007901
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 11:05:03 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p23IHmv2117260
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 11:17:48 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p23IHmS9022246
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 11:17:48 -0700
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1299174652.2071.12.camel@dan>
References: <1299174652.2071.12.camel@dan>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 03 Mar 2011 10:17:46 -0800
Message-ID: <1299176266.8493.2369.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2011-03-03 at 12:50 -0500, Dan Rosenberg wrote:
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4691,7 +4691,7 @@ static const struct file_operations proc_slabinfo_operations = {
> 
>  static int __init slab_proc_init(void)
>  {
> -       proc_create("slabinfo", S_IRUGO, NULL, &proc_slabinfo_operations);
> +       proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
>         return 0;
>  }
>  module_init(slab_proc_init); 

Please don't.  In reality, it'll just mean that more data collection
things will have to get done as root, and I'll wear my keyboard out more
often sudo'ing.

If you really want this on particularly pedantic systems, why not chmod?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
