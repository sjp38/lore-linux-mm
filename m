Date: Sun, 18 Apr 2004 12:05:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: vmscan.c heuristic adjustment for smaller systems
Message-ID: <20040418190514.GC743@holomorphy.com>
References: <20040418174743.GC28744@flea> <20040418175324.GB743@holomorphy.com> <20040418180614.GA29280@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040418180614.GA29280@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 18, 2004 at 10:53:24AM -0700, William Lee Irwin III wrote:
>> Well, there's a point of some kind to it.

On Sun, Apr 18, 2004 at 11:06:14AM -0700, Marc Singer wrote:
> I don't think I understand what you mean.

Feeding the replacement heuristics better input tends to get better
results, or something on that order.


On Sun, Apr 18, 2004 at 10:53:24AM -0700, William Lee Irwin III wrote:
>> Actually ptep_to_address() should find the uvaddr for you.

On Sun, Apr 18, 2004 at 11:06:14AM -0700, Marc Singer wrote:
> The set_pte function is assembler coded.  For a proof of concept, I am
> willing to be blunt.

If you're stuck examining struct page you might want to keep it in C for
a while.


On Sun, Apr 18, 2004 at 10:53:24AM -0700, William Lee Irwin III wrote:
>> I'm not going to tell ou what your results are.

On Sun, Apr 18, 2004 at 11:06:14AM -0700, Marc Singer wrote:
> Perhaps, though, this isn't such a bad result.  It could mean that the
> lazy TLB flush is OK and that my bug is something different.  Or, it
> could mean that I'm still doing the flush incorrectly and that that is
> the correct solution were it done right.

Was this the one-liner in vmscan.c from earlier?


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
