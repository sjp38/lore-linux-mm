Date: Fri, 10 Aug 2007 10:56:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/5] vmemmap: generify initialisation via helpers
In-Reply-To: <E1IJVf4-0004oZ-6G@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0708101055360.13640@schroedinger.engr.sgi.com>
References: <exportbomb.1186756801@pinky> <E1IJVf4-0004oZ-6G@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

That exports a series of new function. The function are always compiled in 
even if not needed right?

Acked-by: Christoph Lameter <clameter@sgi.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
