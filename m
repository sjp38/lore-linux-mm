Received: by py-out-1112.google.com with SMTP id a25so2075481pyi
        for <linux-mm@kvack.org>; Tue, 19 Jun 2007 13:58:12 -0700 (PDT)
Message-ID: <84144f020706191358j1992dd50ga5d93efbd61878d6@mail.gmail.com>
Date: Tue, 19 Jun 2007 23:58:12 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 11/26] SLUB: Add support for kmem_cache_ops
In-Reply-To: <20070618095916.083793990@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070618095838.238615343@sgi.com>
	 <20070618095916.083793990@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On 6/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> We use the parameter formerly used by the destructor to pass an optional
> pointer to a kmem_cache_ops structure to kmem_cache_create.
>
> kmem_cache_ops is created as empty. Later patches populate kmem_cache_ops.

I like kmem_cache_ops but I don't like this patch. I know its painful
but we really want the introduction patch to fixup the API (move ctor
to kmem_cache_ops and do the callers).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
