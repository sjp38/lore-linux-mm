Received: by nz-out-0506.google.com with SMTP id f1so1605874nzc
        for <linux-mm@kvack.org>; Sat, 19 May 2007 05:53:04 -0700 (PDT)
Message-ID: <84144f020705190553s598e722fu7279253ee8b516bc@mail.gmail.com>
Date: Sat, 19 May 2007 15:53:04 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 01/10] SLUB: add support for kmem_cache_ops
In-Reply-To: <20070518181118.828853654@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070518181040.465335396@sgi.com>
	 <20070518181118.828853654@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "clameter@sgi.com" <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On 5/18/07, clameter@sgi.com <clameter@sgi.com> wrote:
> kmem_cache_ops is created as empty. Later patches populate kmem_cache_ops.

Hmm, would make more sense to me to move "ctor" in kmem_cache_ops in
this patch and not make kmem_cache_create() take both as parameters...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
