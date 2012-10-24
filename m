Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 8F7B76B0075
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:34:01 -0400 (EDT)
Date: Wed, 24 Oct 2012 17:33:59 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into slab_common
Message-ID: <20121024153359.GK16230@one.firstfloor.org>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com> <1351087158-8524-2-git-send-email-glommer@parallels.com> <0000013a932d456c-8f0cbbce-e3f7-4f2a-b051-7b093a8cfc7e-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013a932d456c-8f0cbbce-e3f7-4f2a-b051-7b093a8cfc7e-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

On Wed, Oct 24, 2012 at 02:29:09PM +0000, Christoph Lameter wrote:
> On Wed, 24 Oct 2012, Glauber Costa wrote:
> 
> > Because of that, we either have to move all the entry points to the
> > mm/slab.h and rely heavily on the pre-processor, or include all .c files
> > in here.
> 
> Hmm... That is a bit of a radical solution. The global optimizations now
> possible with the new gcc compiler include the ability to fold functions
> across different linkable objects. Andi, is that usable for kernel builds?

Yes, but you need a fairly large patchkit which is not mainline yet.

https://github.com/andikleen/linux-misc/tree/lto

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
