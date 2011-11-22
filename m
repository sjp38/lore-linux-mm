Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 20C466B00BB
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 18:59:04 -0500 (EST)
Date: Tue, 22 Nov 2011 15:59:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] cleanup: convert the int cnt to unsigned long in
 mm/memblock.c
Message-Id: <20111122155901.e7b23dce.akpm@linux-foundation.org>
In-Reply-To: <4EBA0D3D.1090808@gmail.com>
References: <4EB9DF0B.7050004@gmail.com>
	<4EBA0D3D.1090808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Sheng-Hui <shhuiw@gmail.com>
Cc: yinghai@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 09 Nov 2011 13:18:53 +0800
Wang Sheng-Hui <shhuiw@gmail.com> wrote:

> @@ -111,7 +112,7 @@ static phys_addr_t __init_memblock memblock_find_region(phys_addr_t start, phys_
>  static phys_addr_t __init_memblock memblock_find_base(phys_addr_t size,
>  			phys_addr_t align, phys_addr_t start, phys_addr_t end)
>  {
> -	long i;
> +	unsigned long i;
>  
>  	BUG_ON(0 == size);

This change to memblock_find_base() can cause this loop:

	for (i = memblock.memory.cnt - 1; i >= 0; i--) {

to become infinite under some circumstances.

I stopped reading at that point.  Changes like this require much care.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
