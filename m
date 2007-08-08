Date: Wed, 8 Aug 2007 11:06:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <1186557865.7182.86.camel@twins>
Message-ID: <Pine.LNX.4.64.0708081104570.12652@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl>  <200708061559.41680.phillips@phunq.net>
  <Pine.LNX.4.64.0708061605400.5090@schroedinger.engr.sgi.com>
 <200708061649.56487.phillips@phunq.net>  <Pine.LNX.4.64.0708071513290.3683@schroedinger.engr.sgi.com>
 <1186557865.7182.86.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Daniel Phillips <phillips@phunq.net>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 8 Aug 2007, Peter Zijlstra wrote:

> Christoph, does this all explain the situation?

Sort of. I am still very sceptical that this will work reliably. I'd 
rather look at alternate solution like fixing reclaim. Could you have a 
look at Andrew's and my comments on the slub patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
