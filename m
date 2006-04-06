From: Con Kolivas <kernel@kolivas.org>
Subject: Re: Respin: [PATCH] mm: limit lowmem_reserve
Date: Thu, 6 Apr 2006 12:58:40 +1000
References: <200604021401.13331.kernel@kolivas.org> <20060405194344.1915b57a.akpm@osdl.org> <200604061255.55055.kernel@kolivas.org>
In-Reply-To: <200604061255.55055.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604061258.40487.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ck@vds.kolivas.org
Cc: Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 06 April 2006 12:55, Con Kolivas wrote:
> On Thursday 06 April 2006 12:43, Andrew Morton wrote:
> > Con Kolivas <kernel@kolivas.org> wrote:
> > > It is possible with a low enough lowmem_reserve ratio to make
> > >  zone_watermark_ok fail repeatedly if the lower_zone is small enough.
> >
> > Is that actually a problem?
>
> Every single call to get_page_from_freelist will call on zone reclaim. It
> seems a problem to me if every call to __alloc_pages will do that?

every call to __alloc_pages of that zone I mean

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
