Received: by rv-out-0910.google.com with SMTP id l15so1267619rvb
        for <linux-mm@kvack.org>; Tue, 23 Oct 2007 13:41:42 -0700 (PDT)
Message-ID: <84144f020710231341p189435b1y5514e5be981b9b1c@mail.gmail.com>
Date: Tue, 23 Oct 2007 23:41:42 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: SLUB 0:1 SLAB (OOM during massive parallel kernel builds)
In-Reply-To: <Pine.LNX.4.64.0710231305050.20095@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071023181615.GA10377@martell.zuzino.mipt.ru>
	 <Pine.LNX.4.64.0710231227590.19626@schroedinger.engr.sgi.com>
	 <84144f020710231304h6cba8626na4ab4bec0acda7a0@mail.gmail.com>
	 <Pine.LNX.4.64.0710231305050.20095@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

(I fixed linux-mm cc to kvack.org.)

On 10/23/07, Christoph Lameter <clameter@sgi.com> wrote:
> The number of objects per page is reduced by enabling full debugging. That
> triggers a potential of more order 1 allocations but we are failing at
> order 0 allocs.

Yeah, but we're _not failing_ when debugging is enabled. Thus, it's
likely, that the _failing_ (non-debug) case has potential for more
order 0 allocs, no? I am just guessing here but maybe it's
slab_order() behaving differently from calculate_slab_order() so that
we see more order 0 pressure in SLUB than SLAB?

                                     Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
