Message-ID: <4831BF0C.4010905@cs.helsinki.fi>
Date: Mon, 19 May 2008 20:55:24 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] Fix to return wrong pointer in slob
References: <48317CA8.1080700@gmail.com> <1211218837.18026.116.camel@calx>
In-Reply-To: <1211218837.18026.116.camel@calx>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:
> This looks good, but I would remove the 'else {' and '}' here. It's nice
> to have the 'normal path' minimally indented.
> 
> Otherwise,
> 
> Acked-by: Matt Mackall <mpm@selenic.com>
> 
> [cc:ed to Pekka, who manages the allocator tree]

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
