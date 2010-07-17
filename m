Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D54256B02A4
	for <linux-mm@kvack.org>; Sat, 17 Jul 2010 14:10:25 -0400 (EDT)
Message-ID: <4C41F1FD.50501@redhat.com>
Date: Sat, 17 Jul 2010 14:10:05 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] Allow sharing xvmalloc for zram and zcache
References: <1279283870-18549-1-git-send-email-ngupta@vflare.org> <1279283870-18549-2-git-send-email-ngupta@vflare.org>
In-Reply-To: <1279283870-18549-2-git-send-email-ngupta@vflare.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Avi Kivity <avi@redhat.com>, Christoph Hellwig <hch@infradead.org>, Minchan Kim <minchan.kim@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 07/16/2010 08:37 AM, Nitin Gupta wrote:
> Both zram and zcache use xvmalloc allocator. If xvmalloc
> is compiled separately for both of them, we will get linker
> error if they are both selected as "built-in".
>
> So, we now compile xvmalloc separately and export its symbols
> which are then used by both of zram and zcache.
>
> Signed-off-by: Nitin Gupta<ngupta@vflare.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
