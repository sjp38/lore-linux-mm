Date: Tue, 29 Apr 2008 16:32:39 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <d43160c70804290821i2bb0bc17m21b0c5838631e0b8@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0804291629410.23101@blonde.site>
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
 <Pine.LNX.4.64.0804291447040.5058@blonde.site>
 <661de9470804290752w1dc0cfb3k72e81d828a45765e@mail.gmail.com>
 <d43160c70804290821i2bb0bc17m21b0c5838631e0b8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008, Ross Biro wrote:
> On Tue, Apr 29, 2008 at 10:52 AM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
> >  Hmm.. strange.. I don't remember the overhead being so bad (I'll
> >  relook at my old numbers). I'll try and git-bisect this one
> 
> I'm checking 2.6.24 now.  A quick run of 2.6.25-rc9 without fake numa
> showed no real change.

Worth checking 2.6.24, yes.  But you've already made it clear that
you do NOT have mem cgroups in your 2.6.25-rc9, so Balbir (probably)
need not worry about your regression: my guess was wrong on that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
