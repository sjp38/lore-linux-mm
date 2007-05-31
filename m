Date: Thu, 31 May 2007 10:43:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <20070531073914.GA32365@minantech.com>
Message-ID: <Pine.LNX.4.64.0705311043400.9693@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
 <1180544104.5850.70.camel@localhost> <Pine.LNX.4.64.0705301042320.1195@schroedinger.engr.sgi.com>
 <20070531061836.GL4715@minantech.com> <Pine.LNX.4.64.0705302335050.6733@schroedinger.engr.sgi.com>
 <20070531064753.GA31143@minantech.com> <Pine.LNX.4.64.0705302352590.6824@schroedinger.engr.sgi.com>
 <20070531071110.GB31143@minantech.com> <Pine.LNX.4.64.0705310021380.6969@schroedinger.engr.sgi.com>
 <20070531073914.GA32365@minantech.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 31 May 2007, Gleb Natapov wrote:

> happen (flash file from pagecache before mmap. Is it even possible?).

Hmmm.... fadvise or so I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
