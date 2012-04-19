Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 7D4F66B004D
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 05:19:27 -0400 (EDT)
Date: Thu, 19 Apr 2012 10:19:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: do not leak object after tree insertion
 error (v3)
Message-ID: <20120419091917.GA23597@arm.com>
References: <20120418154448.GA3617@swordfish.minsk.epam.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120418154448.GA3617@swordfish.minsk.epam.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Apr 18, 2012 at 04:44:48PM +0100, Sergey Senozhatsky wrote:
>  [PATCH] kmemleak: do not leak object after tree insertion error
> 
>  In case when tree insertion fails due to already existing object
>  error, pointer to allocated object gets lost because of overwrite
>  with lookup_object() return. Free allocated object before object
>  lookup. 
> 
>  Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Thanks. I applied it to my kmemleak branch and I'll send it to Linus at
some point (during the next merging window).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
