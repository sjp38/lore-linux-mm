Message-ID: <4028DF9C.2070804@cyberone.com.au>
Date: Wed, 11 Feb 2004 00:41:48 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] skip offline CPUs in show_free_areas
References: <20040210132301.GA11045@lst.de>
In-Reply-To: <20040210132301.GA11045@lst.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Christoph Hellwig wrote:

>Without this ouput on a box with 8cpus and NR_CPUS=64 looks rather
>strange.
>
>

You should probably just use for_each_online_cpu()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
