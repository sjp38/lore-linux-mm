Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 003366B0083
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 03:11:19 -0500 (EST)
Date: Tue, 11 Dec 2012 17:11:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v3] Support volatile range for anon vma
Message-ID: <20121211081117.GH22698@blaptop>
References: <1355193255-7217-1-git-send-email-minchan@kernel.org>
 <20121211024104.GA10523@blaptop>
 <20121211071742.GA26598@glandium.org>
 <20121211073744.GF22698@blaptop>
 <20121211075950.GA27103@glandium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121211075950.GA27103@glandium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Hommey <mh@glandium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 11, 2012 at 08:59:50AM +0100, Mike Hommey wrote:
> On Tue, Dec 11, 2012 at 04:37:44PM +0900, Minchan Kim wrote:
> > On Tue, Dec 11, 2012 at 08:17:42AM +0100, Mike Hommey wrote:
> > > On Tue, Dec 11, 2012 at 11:41:04AM +0900, Minchan Kim wrote:
> > > > - What's the madvise(addr, length, MADV_VOLATILE)?
> > > > 
> > > >   It's a hint that user deliver to kernel so kernel can *discard*
> > > >   pages in a range anytime.
> > > > 
> > > > - What happens if user access page(ie, virtual address) discarded
> > > >   by kernel?
> > > > 
> > > >   The user can see zero-fill-on-demand pages as if madvise(DONTNEED).
> > > 
> > > What happened to getting SIGBUS?
> > 
> > I thought it could force for user to handle signal.
> > If user can receive signal, what can he do?
> > Maybe he can call madivse(NOVOLATILE) in my old version but I removed it
> > in this version so user don't need handle signal handling.
> 
> NOVOLATILE and signal throwing are two different and not necessarily
> related needs. We (Mozilla) could probably live without NOVOLATILE,
> but certainly not without signal throwing.

What's shortcoming if we don't provide signal handling?
Could you explain how you want to signal in your allocator?

It could be very helpful to improve this patch.
Thanks for the input.

> 
> Mike
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
