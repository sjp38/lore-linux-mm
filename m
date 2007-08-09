Date: Thu, 9 Aug 2007 11:49:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0708091146410.25220@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <200708061559.41680.phillips@phunq.net>
  <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
 <200708061649.56487.phillips@phunq.net>  <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
  <4a5909270708080037n32be2a73k5c28d33bb02f770b@mail.gmail.com>
 <Pine.LNX.4.64.0708081106230.12652@schroedinger.engr.sgi.com>
 <4a5909270708091141tb259eddyb2bba1270751ef1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <daniel.raymond.phillips@gmail.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2007, Daniel Phillips wrote:

> On 8/8/07, Christoph Lameter <clameter@sgi.com> wrote:
> > On Wed, 8 Aug 2007, Daniel Phillips wrote:
> > Maybe we need to kill PF_MEMALLOC....
> 
> Shrink_caches needs to be able to recurse into filesystems at least,
> and for the duration of the recursion the filesystem must have
> privileged access to reserves.  Consider the difficulty of handling
> that with anything other than a process flag.

Shrink_caches needs to allocate memory? Hmmm... Maybe we can only limit 
the PF_MEMALLOC use.

> In theory, we could reduce the size of the global memalloc pool by
> including "easily freeable" memory in it.  This is just an
> optimization and does not belong in this patch set, which fixes a
> system integrity issue.

I think the main thing would be to fix reclaim to not do stupid things 
like triggering writeout early in the reclaim pass and to allow reentry 
into reclaim. The idea of memory pools always sounded strange to me given 
that you have a lot of memory in a zone that is reclaimable as needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
