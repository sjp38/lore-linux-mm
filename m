Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 74A5D6B0288
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 15:31:07 -0500 (EST)
Subject: Re: [rfc 03/18] slub: Extract get_freelist from __slab_alloc
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <alpine.DEB.2.00.1111151008220.22502@router.home>
References: <20111111200711.156817886@linux.com>
	 <20111111200726.995401746@linux.com>
	 <CAOJsxLGbWe_hND9B8UbQyg5UN2Ydaes3wcWYzXu4goD8V9F6_Q@mail.gmail.com>
	 <alpine.DEB.2.00.1111151008220.22502@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 13 Dec 2011 22:31:04 +0200
Message-ID: <1323808264.1428.310.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Tue, 2011-11-15 at 10:08 -0600, Christoph Lameter wrote:
> On Mon, 14 Nov 2011, Pekka Enberg wrote:
> 
> > On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> > > get_freelist retrieves free objects from the page freelist (put there by remote
> > > frees) or deactivates a slab page if no more objects are available.
> > >
> > > Signed-off-by: Christoph Lameter <cl@linux.com>
> >
> > This is a also a nice cleanup. Any reason I shouldn't apply this?
> 
> Cannot think of any reason not to apply this patch.

I ended up applying only one of the cleanups David ACK'd. I got too many
rejects when applying for the other ones.

			Pekka 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
