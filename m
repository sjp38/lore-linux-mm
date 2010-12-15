Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 58B1C6B0095
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 11:50:15 -0500 (EST)
Message-ID: <4D08F1A2.6040801@redhat.com>
Date: Wed, 15 Dec 2010 11:49:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
In-Reply-To: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 12/15/2010 10:49 AM, Miklos Szeredi wrote:
> From: Miklos Szeredi<mszeredi@suse.cz>
>
> This function basically does:
>
>       remove_from_page_cache(old);
>       page_cache_release(old);
>       add_to_page_cache_locked(new);
>
> Except it does this atomically, so there's no possibility for the
> "add" to fail because of a race.
>
> This is used by fuse to move pages into the page cache.
>
> Signed-off-by: Miklos Szeredi<mszeredi@suse.cz>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
