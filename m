Received: by rv-out-0910.google.com with SMTP id f1so3339230rvb.26
        for <linux-mm@kvack.org>; Sat, 01 Mar 2008 01:47:07 -0800 (PST)
Message-ID: <84144f020803010147y489b06fdx479ed0af931de08b@mail.gmail.com>
Date: Sat, 1 Mar 2008 11:47:07 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 7/8] slub: Make the order configurable for each slab cache
In-Reply-To: <Pine.LNX.4.64.0802291137140.11084@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080229044803.482012397@sgi.com>
	 <20080229044820.044485187@sgi.com> <47C7BEA8.4040906@cs.helsinki.fi>
	 <Pine.LNX.4.64.0802291137140.11084@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Fri, 29 Feb 2008, Pekka Enberg wrote:
>  > I think we either want to check that the order is big enough to hold one
>  > object for the given cache or add a comment explaining why it can never happen
>  > (page allocator pass-through).

On Fri, Feb 29, 2008 at 9:37 PM, Christoph Lameter <clameter@sgi.com> wrote:
>  Calculate_sizes() will violate max_order if the object does not fit.

I am not sure I understand what you mean here. For example, for a
cache that requires minimum order of 1 to fit any objects (which
doesn't happen now because of page allocator pass-through), the
order_store() function can call calculate_sizes() with forced_order
set to zero after which the cache becomes useless. That deserves a
code comment, I think.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
