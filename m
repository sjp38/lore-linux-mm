Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 97C066B00B6
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 12:23:50 -0500 (EST)
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <E1PZXeb-0004AV-2b@tytso-glaptop>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 03 Jan 2011 11:23:46 -0600
Message-ID: <1294075426.3109.99.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 2011-01-02 at 18:48 -0500, Theodore Ts'o wrote:
> Given the patches being busily submitted by trivial patch submitters to
> make use kmem_cache_zalloc(), et. al, I believe we should remove the
> unlikely() tests around the (gfp_flags & __GFP_ZERO) tests, such as:
> 
> -	if (unlikely((flags & __GFP_ZERO) && objp))
> +	if ((flags & __GFP_ZERO) && objp)
> 		memset(objp, 0, obj_size(cachep));
> 
> Agreed?  If so, I'll send a patch...

Sounds good to me.

We might consider dropping this flag and making the decision statically
(ie alloc vs zalloc), at least for slab objects.

-- 
Mathematics is the supreme nostalgia of our time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
