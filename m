Date: Wed, 6 Jun 2007 20:49:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Use ilog2 instead of series of constant comparisons.
In-Reply-To: <29495f1d0706061701g449b0074ne329a7b7375efc56@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706062047220.19420@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705211250410.27950@schroedinger.engr.sgi.com>
 <20070606100817.7af24b74.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061053290.11553@schroedinger.engr.sgi.com>
 <20070606131121.a8f7be78.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061326020.12565@schroedinger.engr.sgi.com>
 <20070606133432.2f3cb26a.akpm@linux-foundation.org>  <46671C16.9080409@mbligh.org>
  <Pine.LNX.4.64.0706061349451.12665@schroedinger.engr.sgi.com>
 <20070606161909.ea6a2556.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706061646230.18160@schroedinger.engr.sgi.com>
 <29495f1d0706061701g449b0074ne329a7b7375efc56@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Jun 2007, Nish Aravamudan wrote:

> > clameter@schroedinger:~/software/slub$ cat /usr/local/bin/make_powerpc
> > make ARCH=powerpc CROSS_COMPILE=powerpc-linux-gnu- $*
> 
> Hrm, what does V=1 say? Perhaps you need to somehow pass in -m64 or
> something, if it's a biarch compiler (ppc32 and ppc64)?

No idea if that is the case but should the kernel not automagically adjust 
to that?

V=1 does not add additional output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
