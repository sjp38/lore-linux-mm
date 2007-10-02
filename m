Date: Tue, 2 Oct 2007 09:32:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][-mm only] Error handling in walk_memory_resource()
Message-Id: <20071002093232.23798e7e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1191276438.30691.13.camel@dyn9047017100.beaverton.ibm.com>
References: <1191276438.30691.13.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 01 Oct 2007 15:07:18 -0700
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> Index: linux-2.6.23-rc8/kernel/resource.c
> ===================================================================
> --- linux-2.6.23-rc8.orig/kernel/resource.c	2007-10-01 14:09:01.000000000 -0700
> +++ linux-2.6.23-rc8/kernel/resource.c	2007-10-01 14:09:35.000000000 -0700
> @@ -284,7 +284,7 @@ walk_memory_resource(unsigned long start
>  	struct resource res;
>  	unsigned long pfn, len;
>  	u64 orig_end;
> -	int ret;
> +	int ret = -1;

Thank you! 
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
