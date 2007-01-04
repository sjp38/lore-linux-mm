Message-ID: <459C8833.7080500@yahoo.com.au>
Date: Thu, 04 Jan 2007 15:53:07 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [2.6 patch] the scheduled find_trylock_page() removal
References: <20070102215735.GD20714@stusta.de>
In-Reply-To: <20070102215735.GD20714@stusta.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@stusta.de>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Adrian Bunk wrote:
> This patch contains the scheduled find_trylock_page() removal.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

I guess I don't have a problem with this going into -mm and making its way
upstream sometime after the next release.

I would normally say it is OK to stay for another year because it is so
unintrusive, but I don't like the fact it doesn't give one an explicit ref
on the page -- it could be misused slightly more easily than find_lock_page
or find_get_page.

Anyone object? Otherwise:

Acked-by: Nick Piggin <npiggin@suse.de>

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
