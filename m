Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A16996B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 08:28:27 -0400 (EDT)
Message-ID: <4A2D15DD.1030005@redhat.com>
Date: Mon, 08 Jun 2009 09:45:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Add a gfp-translate script to help understand page	allocation
 failure reports
References: <20090608132950.GB15070@csn.ul.ie>
In-Reply-To: <20090608132950.GB15070@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

>   mel@machina:~/linux-2.6 $ scripts/gfp-translate 0x4020
>   Source: /home/mel/linux-2.6
>   Parsing: 0x4020
>   #define __GFP_HIGH	(0x20)	/* Should access emergency pools? */
>   #define __GFP_COMP	(0x4000) /* Add compound page metadata */
> 
> The script is not a work of art but it has come in handy for me a few times
> so I thought I would share.

Sweet.  This is just what I've been waiting for!

> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
