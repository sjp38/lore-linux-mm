Date: Tue, 1 May 2007 20:10:26 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: 2.6.21-rc7-mm2 crash: Eeek! page_mapcount(page) went negative!
	(-1)
Message-ID: <20070502031026.GD6784@suse.de>
References: <20070425225716.8e9b28ca.akpm@linux-foundation.org> <46338AEB.2070109@imap.cc> <20070428141024.887342bd.akpm@linux-foundation.org> <4636248E.7030309@imap.cc> <20070430112130.b64321d3.akpm@linux-foundation.org> <46364346.6030407@imap.cc> <20070430124638.10611058.akpm@linux-foundation.org> <463723F4.8060009@imap.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <463723F4.8060009@imap.cc>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tilman Schmidt <tilman@imap.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 01:26:44PM +0200, Tilman Schmidt wrote:
> Am 30.04.2007 21:46 schrieb Andrew Morton:
> > Sure, but what about 2.6.21-git3 (or, better, current -git)?
> 
> 2.6.21-git3 crashed with panic blink at "scanning usb: .."
> (Nothing in the log this time.)

Eeek, that's not good.

Can you keep bisecting Linus's tree?  'git bisect' makes this very easy
to do.  We need to track this down as soon as possible if we can.

> Will continue bisecting -rc7-mm2.

Can you focus on Linus's tree now, as we know that it is the part
causing problems?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
