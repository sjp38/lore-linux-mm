From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [ck] Re: [PATCH] mm: implement swap prefetching
Date: Tue, 7 Feb 2006 12:32:52 +1100
References: <200602071028.30721.kernel@kolivas.org> <20060206163842.7ff70c49.akpm@osdl.org> <200602071229.25793.kernel@kolivas.org>
In-Reply-To: <200602071229.25793.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602071232.52897.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ck@vds.kolivas.org
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Feb 2006 12:29 pm, Con Kolivas wrote:
> On Tue, 7 Feb 2006 11:38 am, Andrew Morton wrote:
> > Con Kolivas <kernel@kolivas.org> wrote:
> > > +	if (unlikely(!spin_trylock(&swapped.lock)))
> > > +		goto out;
> >
> > hm, spin_trylock() should internally do unlikely(), but it doesn't. 
> > (It's a bit of a mess, too).
>
> Good point. Perhaps I should submit a separate patch for this instead.

A quick look at this code made me change my mind; there's heaps that could do 
with this treatment in spinlock.h. I'll let someone else tackle it.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
