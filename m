Received: by ug-out-1314.google.com with SMTP id o2so93288uge
        for <linux-mm@kvack.org>; Fri, 04 Aug 2006 08:59:15 -0700 (PDT)
Message-ID: <84144f020608040859o7e7b9a83p492e936af8a6e921@mail.gmail.com>
Date: Fri, 4 Aug 2006 18:59:15 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 2/2] slab: optimize kmalloc_node the same way as kmalloc
In-Reply-To: <20060804151546.GB29422@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20060804151546.GB29422@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: akpm@osdl.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On 8/4/06, Christoph Hellwig <hch@lst.de> wrote:
> +static inline void *kmalloc_node(size_t size, gfp_t flags, int node)

[snip]

I think the optimization was left out on purpose as kmalloc_node() is
slow anyway. No objections from me though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
