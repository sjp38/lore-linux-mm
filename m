Date: Mon, 13 Aug 2007 16:04:22 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <200708122355.34652.phillips@phunq.net>
Message-ID: <Pine.LNX.4.64.0708131603590.18204@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>
 <4a5909270708100115v4ad10c4es697d216edf29b07d@mail.gmail.com>
 <Pine.LNX.4.64.0708101041040.12758@schroedinger.engr.sgi.com>
 <200708122355.34652.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: Daniel Phillips <daniel.raymond.phillips@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Sun, 12 Aug 2007, Daniel Phillips wrote:

> > Because we get to the code of interest when we have no memory on the
> > buddy free lists...
> 
> Ah wait, that statement is incorrect and may well be the crux of your 
> misunderstanding.  Buddy free lists are not exhausted until the entire 
> memalloc reserve has been depleted, which would indicate a kernel bug 
> and imminent system death.

I added the call to reclaim where the memory is out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
