Received: by wa-out-1112.google.com with SMTP id m33so2401950wag
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:08:03 -0700 (PDT)
Message-ID: <84144f020706181308v689254dl80a5dd42ba6014c4@mail.gmail.com>
Date: Mon, 18 Jun 2007 23:08:03 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 03/26] Slab allocators: Consistent ZERO_SIZE_PTR support and NULL result semantics
In-Reply-To: <20070618095914.097484951@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095914.097484951@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> Define ZERO_OR_NULL_PTR macro to be able to remove the checks
> from the allocators. Move ZERO_SIZE_PTR related stuff into slab.h.
>
> Make ZERO_SIZE_PTR work for all slab allocators and get rid of the
> WARN_ON_ONCE(size == 0) that is still remaining in SLAB.
>
> Make slub return NULL like the other allocators if a too large
> memory segment is requested via __kmalloc.

Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
