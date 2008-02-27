Date: Wed, 27 Feb 2008 11:40:18 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SMP-related kernel memory leak
In-Reply-To: <e2e108260802230008y4179970dw6581c1a361eac280@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0802271139090.1790@schroedinger.engr.sgi.com>
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>
 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>
 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>
 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
 <6101e8c40802210825v534f0ce3wf80a18ebd6dee925@mail.gmail.com>
 <47BDEFB4.1010106@zytor.com>  <6101e8c40802220844h2553051bw38154dbad91de1e3@mail.gmail.com>
  <47BEFD5D.402@zytor.com>  <6101e8c40802221512t295566bey5a8f1c21b8751480@mail.gmail.com>
  <47BF5932.9040200@zytor.com> <e2e108260802230008y4179970dw6581c1a361eac280@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bart Van Assche <bart.vanassche@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Oliver Pinter <oliver.pntr@gmail.com>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Sat, 23 Feb 2008, Bart Van Assche wrote:

> The patch referenced above modifies a single file:
> include/asm-generic/tlb.h. I had a look at the git history of Linus'
> 2.6.24 tree, and noticed that the cited patch was applied on December
> 18, 2007 to Linus' tree by Christoph Lameter. Two weeks later, on
> December 27, the change was reverted by Christoph. Christoph, can you
> provide us some more background information about why the patch was
> reverted ?

It did not fix the problem that was reported. Commit 
96990a4ae979df9e235d01097d6175759331e88c took its place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
