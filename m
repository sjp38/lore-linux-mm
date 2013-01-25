Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 772766B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 16:52:36 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id ro12so448489pbb.24
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 13:52:35 -0800 (PST)
Date: Fri, 25 Jan 2013 13:52:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] kernel/res_counter.c: move BUG() to the default choice
 of switch at res_counter_member()
In-Reply-To: <51023F89.9030807@oracle.com>
Message-ID: <alpine.DEB.2.00.1301251352030.26610@chino.kir.corp.google.com>
References: <51023F89.9030807@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, 25 Jan 2013, Jeff Liu wrote:

> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index ff55247..748a3bc 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -135,10 +135,9 @@ res_counter_member(struct res_counter *counter, int member)
>  		return &counter->failcnt;
>  	case RES_SOFT_LIMIT:
>  		return &counter->soft_limit;
> +	default:
> +		BUG();
>  	};
> -
> -	BUG();
> -	return NULL;
>  }
>  
>  ssize_t res_counter_read(struct res_counter *counter, int member,

This doesn't work for CONFIG_BUG=n, you still need a return value.  I 
think the original version was better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
