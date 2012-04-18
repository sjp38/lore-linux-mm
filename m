Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1C58D6B0092
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 10:40:54 -0400 (EDT)
Date: Wed, 18 Apr 2012 15:40:44 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: do not leak object after tree insertion
 error (v2, fixed)
Message-ID: <20120418144043.GH1505@arm.com>
References: <20120402230656.GA4353@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120402230656.GA4353@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Apr 03, 2012 at 12:06:56AM +0100, Sergey Senozhatsky wrote:
> [PATCH] kmemleak: do not leak object after tree insertion error
> 
> In case when tree insertion fails due to already existing object
> error, pointer to allocated object gets lost due to lookup_object()
> overwrite. Free allocated object and return the existing one, 
> obtained from lookup_object().

We really need to return NULL if the tree insertion fails as kmemleak is
disabled in this case (fatal condition for kmemleak). So we could just
call kmem_cache_free(object_cache, object) in the 'if' block.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
