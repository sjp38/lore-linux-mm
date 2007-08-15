Message-ID: <46C313B3.4020409@shadowen.org>
Date: Wed, 15 Aug 2007 15:54:43 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] vmemmap: generify initialisation via helpers
References: <exportbomb.1186756801@pinky> <E1IJVf4-0004oZ-6G@localhost.localdomain> <Pine.LNX.4.64.0708101055360.13640@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708101055360.13640@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> That exports a series of new function. The function are always compiled in 
> even if not needed right?
> 
> Acked-by: Christoph Lameter <clameter@sgi.com>

Yes.  We are assuming the compiler is going to help us out.  They are
mostly trivial and all __meminit.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
