Message-ID: <3F614912.3090801@genebrew.com>
Date: Fri, 12 Sep 2003 00:18:26 -0400
From: Rahul Karnik <rahul@genebrew.com>
MIME-Version: 1.0
Subject: Re: [RFC] Enabling other oom schemes
References: <200309120219.h8C2JANc004514@penguin.co.intel.com>
In-Reply-To: <200309120219.h8C2JANc004514@penguin.co.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rusty@linux.co.intel.com
Cc: riel@conectiva.com.br, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rusty Lynch wrote:
> The patch below uses a notifier list for other components to register
> to be called when an out of memory condition occurs.

How does this interact with the overcommit handling? Doesn't strict 
overcommit also not oom, but rather return a memory allocation error? 
Could we not add another overcommit mode where oom conditions cause a 
kernel panic?

Thanks,
Rahul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
