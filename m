Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1E2326B01B5
	for <linux-mm@kvack.org>; Tue, 25 May 2010 13:03:44 -0400 (EDT)
Date: Tue, 25 May 2010 10:00:03 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: TMPFS over NFSv4
Message-ID: <20100525170003.GD9154@suse.de>
References: <AANLkTik47c6l3y8CdJ-hUCd2h3SRSb3qAtRovWryb8_p@mail.gmail.com>
 <alpine.LSU.2.00.1005211344440.7369@sister.anvils>
 <AANLkTil7I6q4wdLgmwZdRN6hb9LVVagN_7oGTIVNDhUk@mail.gmail.com>
 <AANLkTilMQjZaUom2h_aFgU6WB83IGH-VVKTg-CJD-_ZZ@mail.gmail.com>
 <20100524110903.72524853@lxorguk.ukuu.org.uk>
 <alpine.LSU.2.00.1005241624130.28773@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1005241624130.28773@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 04:46:24PM -0700, Hugh Dickins wrote:
> Hi Greg,
> 
> On Mon, 24 May 2010, Alan Cox wrote:
> > On Mon, 24 May 2010 02:57:30 -0700
> > Hugh Dickins <hughd@google.com> wrote:
> > > On Mon, May 24, 2010 at 2:26 AM, Tharindu Rukshan Bamunuarachchi
> > > <btharindu@gmail.com> wrote:
> > > > thankx a lot Hugh ... I will try this out ... (bit harder patch
> > > > already patched SLES kernel :-p ) ....
> > > 
> > > If patch conflicts are a problem, you really only need to put in the
> > > two-liner patch to mm/mmap.c: Alan was seeking perfection in
> > > the rest of the patch, but you can get away without it.
> > > 
> > > >
> > > > BTW, what does Alan means by "strict overcommit" ?
> > > 
> > > Ah, that phrase, yes, it's a nonsense, but many of us do say it by mistake.
> > > Alan meant to say "strict no-overcommit".
> > 
> > No I always meant to say 'strict overcommit'. It avoids excess negatives
> > and "no noovercommit" discussions.
> > 
> > I guess 'strict overcommit control' would have been clearer 8)
> > 
> > Alan
> 
> I see we've just missed 2.6.27.47-rc1, but if there's to be an -rc2,
> please include Alan's 2.6.28 oops fix below: which Tharindu appears
> to be needing - just now discussed on linux-mm and linux-nfs.
> Failing that, please queue it up for 2.6.27.48.


There is now going to be a -rc2 due to other problems, so I'll go queue
this one up as well.

> Or if you'd prefer a smaller patch for -stable, then just the mm/mmap.c
> part of it should suffice: I think it's fair to say that the rest of the
> patch was more precautionary - as Alan describes, for catching other bugs,
> so good for an ongoing development tree, but not necessarily in -stable.
> (However, Alan may disagree - I've already misrepresented him once here!)

The original is best, it makes more sense.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
