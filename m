Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id BE5296B00E8
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 11:30:05 -0400 (EDT)
Received: by werj55 with SMTP id j55so6809853wer.14
        for <linux-mm@kvack.org>; Wed, 18 Apr 2012 08:30:04 -0700 (PDT)
Date: Wed, 18 Apr 2012 18:29:48 +0300
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] kmemleak: do not leak object after tree insertion error
 (v2, fixed)
Message-ID: <20120418152947.GA8794@swordfish.minsk.epam.com>
References: <20120402230656.GA4353@swordfish>
 <20120418144043.GH1505@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120418144043.GH1505@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On (04/18/12 15:40), Catalin Marinas wrote:
> On Tue, Apr 03, 2012 at 12:06:56AM +0100, Sergey Senozhatsky wrote:
> > [PATCH] kmemleak: do not leak object after tree insertion error
> > 
> > In case when tree insertion fails due to already existing object
> > error, pointer to allocated object gets lost due to lookup_object()
> > overwrite. Free allocated object and return the existing one, 
> > obtained from lookup_object().
> 
> We really need to return NULL if the tree insertion fails as kmemleak is
> disabled in this case (fatal condition for kmemleak). So we could just
> call kmem_cache_free(object_cache, object) in the 'if' block.
> 

Good point. Thanks a lot for your review!
I was chasing two bugs and sort of messed things up. I'll send v3 shortly.


	Sergey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
