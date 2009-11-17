Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1CB486B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:38:06 -0500 (EST)
From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
Date: Tue, 17 Nov 2009 11:38:02 +0100
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk> <28c262360911170232i307144cnb4ddea2a5389bd8e@mail.gmail.com>
In-Reply-To: <28c262360911170232i307144cnb4ddea2a5389bd8e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200911171138.02458.oliver@neukum.org>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Am Dienstag, 17. November 2009 11:32:36 schrieb Minchan Kim:
> On Tue, Nov 17, 2009 at 7:29 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > On Tue, 17 Nov 2009 16:17:50 +0900 (JST)
> >
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> >> memory, anyone must not prevent it. Otherwise the system cause
> >> mysterious hang-up and/or OOM Killer invokation.
> >
> > So now what happens if we are paging and all our memory is tied up for
> > writeback to a device or CIFS etc which can no longer allocate the memory
> > to complete the write out so the MM can reclaim ?
> >
> > Am I missing something or is this patch set not addressing the case where
> > the writeback thread needs to inherit PF_MEMALLOC somehow (at least for
> > the I/O in question and those blocking it)
> 
> I agree.
> At least, drivers for writeout is proper for using PF_MEMALLOC, I think.

For the same reason error handling should also use it, shouldn't it?

	Regards
		Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
