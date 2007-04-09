Date: Mon, 9 Apr 2007 15:03:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
In-Reply-To: <20070409144107.21287fb8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704091501230.2761@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
 <20070409144107.21287fb8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Apr 2007, Andrew Morton wrote:

> On Mon,  9 Apr 2007 11:25:09 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Quicklists for page table pages V5
> 
> So... we skipped i386 this time?
> 
> I'd have gone squeamish if it was included, due to the mystery crash when
> we (effectively) set the list size to zero.  Someone(tm) should look into 
> that - who knows, it might indicate a problem in generic code.

Yeah too many scary monsters in the i386 arch code. Maybe Bill Irwin can 
take a look at how to make this work? He liked the benchmarking code that 
I posted so he may have the tools to insure that it works right. Maybe he 
can figure out some additional tricks on how to make quicklists work 
better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
