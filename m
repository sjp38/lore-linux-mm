From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH -mm 14/24] Ramfs and Ram Disk pages are unevictable
Date: Fri, 13 Jun 2008 03:57:53 +1000
References: <20080611184214.605110868@redhat.com> <200806130337.57118.nickpiggin@yahoo.com.au> <20080612135014.026cc2e3@cuia.bos.redhat.com>
In-Reply-To: <20080612135014.026cc2e3@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806130357.53669.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Friday 13 June 2008 03:50, Rik van Riel wrote:
> On Fri, 13 Jun 2008 03:37:56 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > > This isn't the case for brd any longer. It doesn't use the buffer
> > > > cache as its backing store, so the buffer cache is reclaimable.
> > >
> > > I know that pages of files that got paged into the page
> > > cache from the ramdisk can be evicted (back to the ram
> > > disk), but how do the brd pages themselves behave?
> >
> > They are not reclaimable. But they have nothing (directly) to do
> > with brd's i_mapping address space, nor are they put on any LRU
> > lists.
>
> Ahhhh, doh!
>
> I'm mailing Andrew a patch right now that undoes the
> brd.c part of patch 14/24. The ramdisk part is correct
> and should stay (afaict).

The ramfs part? Yes, that looks correct to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
