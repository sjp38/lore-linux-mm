Message-ID: <422D42BF.4060506@jp.fujitsu.com>
Date: Tue, 08 Mar 2005 15:14:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2/2 Prezeroing large blocks of pages during allocation
 Version 4
References: <20050307194021.E6A86E594@skynet.csn.ul.ie>
In-Reply-To: <20050307194021.E6A86E594@skynet.csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Hi,

Mel Gorman wrote:

>+#define BITS_PER_ALLOC_TYPE 5
> #define ALLOC_KERNNORCLM 0
> #define ALLOC_KERNRCLM 1
> #define ALLOC_USERRCLM 2
> #define ALLOC_FALLBACK 3
>+#define ALLOC_USERZERO 4
>+#define ALLOC_KERNZERO 5
>

Now, 5bits per  MAX_ORDER pages.
I think it is simpler to use "char[]" for representing type of  memory 
alloc type than bitmap.

Thanks
-- Kame <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
