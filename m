Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4153E8D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 12:06:17 -0400 (EDT)
Date: Sat, 30 Oct 2010 17:55:58 +0200 (CEST)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] percpu: zero memory more efficiently in
 mm/percpu.c::pcpu_mem_alloc()
In-Reply-To: <4CCC2480.70303@kernel.org>
Message-ID: <alpine.LNX.2.00.1010301754490.1572@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1010292354060.24561@swampdragon.chaosbits.net> <4CCC2480.70303@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 30 Oct 2010, Tejun Heo wrote:

> Don't do vmalloc() + memset() when vzalloc() will do.
> 
> tj: dropped unnecessary temp variable ptr.
> 
I must be needing glasses, I should have seen that initially. Thanks for 
fixing that up :)

-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
