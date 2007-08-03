Date: Fri, 3 Aug 2007 09:58:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/4] vmemmap: pull out the vmemmap code into its own file
In-Reply-To: <46B3424F.7010800@shadowen.org>
Message-ID: <Pine.LNX.4.64.0708030939140.17307@schroedinger.engr.sgi.com>
References: <exportbomb.1186045945@pinky> <E1IGWw3-0002Xr-Dm@hellhawk.shadowen.org>
 <20070802132621.GA9511@infradead.org> <Pine.LNX.4.64.0708021220220.7948@schroedinger.engr.sgi.com>
 <46B3424F.7010800@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2007, Andy Whitcroft wrote:

> As the PMD initialisers are only used by x86_64 we could make it supply
> a complete vmemmap_populate level initialiser but that would result in
> us duplicating the PUD level initialier function there which seems like
> a bad idea.

Hmmm... at least i386 also uses it. Looked through the other arches but 
cannot find evidence of them supporting PMD level huge page stuff.

There are some embedded archs (example FRV) which seem to be i386 knock 
offs and those also support the same in hardware. There is some 
rudimentary PSE suport in FRV. Has mk_pte_huge(). So I would expect that 
at least i386, x86_64 and FRV would benefit from a generic implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
