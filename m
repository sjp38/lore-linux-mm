Received: by py-out-1112.google.com with SMTP id a25so2071599pyi
        for <linux-mm@kvack.org>; Tue, 19 Jun 2007 13:55:00 -0700 (PDT)
Message-ID: <84144f020706191355m10435927o153e91f16af1c8dd@mail.gmail.com>
Date: Tue, 19 Jun 2007 23:55:00 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 06/26] Slab allocators: Replace explicit zeroing with __GFP_ZERO
In-Reply-To: <20070618095914.862238426@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095914.862238426@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> kmalloc_node() and kmem_cache_alloc_node() were not available in
> a zeroing variant in the past. But with __GFP_ZERO it is possible
> now to do zeroing while allocating.

Looks good. Maybe we want to phase out the zeroing variants altogether
(expect maybe kzalloc which is wide-spread now)?

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
