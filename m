Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3D9AB6B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 11:09:12 -0500 (EST)
Date: Tue, 15 Nov 2011 10:08:56 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [rfc 03/18] slub: Extract get_freelist from __slab_alloc
In-Reply-To: <CAOJsxLGbWe_hND9B8UbQyg5UN2Ydaes3wcWYzXu4goD8V9F6_Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1111151008220.22502@router.home>
References: <20111111200711.156817886@linux.com> <20111111200726.995401746@linux.com> <CAOJsxLGbWe_hND9B8UbQyg5UN2Ydaes3wcWYzXu4goD8V9F6_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Mon, 14 Nov 2011, Pekka Enberg wrote:

> On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> > get_freelist retrieves free objects from the page freelist (put there by remote
> > frees) or deactivates a slab page if no more objects are available.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> This is a also a nice cleanup. Any reason I shouldn't apply this?

Cannot think of any reason not to apply this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
