Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2022D6B0062
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 11:04:17 -0400 (EDT)
Message-ID: <4A2933E4.4040502@redhat.com>
Date: Fri, 05 Jun 2009 11:04:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][mmtom] remove file arguement of swap_readpage
References: <1244212423-18629-1-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1244212423-18629-1-git-send-email-minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Minchan Kim wrote:
> The file argument resulted from address_space's readpage
> long time ago.
> 
> Now we don't use it any more. Let's remove unnecessary
> argement.
> 
> This patch cleans up swap_readpage.
> It doesn't affect behavior of function.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
