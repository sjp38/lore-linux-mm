Received: by nz-out-0506.google.com with SMTP id x7so1544777nzc
        for <linux-mm@kvack.org>; Mon, 18 Jun 2007 13:03:09 -0700 (PDT)
Message-ID: <84144f020706181303q194cba73q1fa158718218e1e9@mail.gmail.com>
Date: Mon, 18 Jun 2007 23:03:08 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 02/26] Slab allocators: Consolidate code for krealloc in mm/util.c
In-Reply-To: <20070618095913.872115919@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095913.872115919@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> The size of a kmalloc object is readily available via ksize().
> ksize is provided by all allocators and thus we canb implement
> krealloc in a generic way.
>
> Implement krealloc in mm/util.c and drop slab specific implementations
> of krealloc.

Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
