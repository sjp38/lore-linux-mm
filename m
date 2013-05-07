Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2CDFB6B003A
	for <linux-mm@kvack.org>; Tue,  7 May 2013 19:56:43 -0400 (EDT)
Message-ID: <518994B9.8020809@sr71.net>
Date: Tue, 07 May 2013 16:56:41 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/7] drain batch list during long operations
References: <20130507211954.9815F9D1@viggo.jf.intel.com> <20130507212003.7990B2F5@viggo.jf.intel.com>
In-Reply-To: <20130507212003.7990B2F5@viggo.jf.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 05/07/2013 02:20 PM, Dave Hansen wrote:
> +++ linux.git-davehans/kernel/sched/fair.c	2013-05-07 13:48:15.275114295 -0700
> @@ -5211,6 +5211,8 @@ more_balance:
>  		if (sd->balance_interval < sd->max_interval)
>  			sd->balance_interval *= 2;
>  	}
> +	//if (printk_ratelimit())
> +	//	printk("sd->balance_interval: %d\n", sd->balance_interval);
>  
>  	goto out;

Urg, this is obviously a garbage hunk that snuck in here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
