Date: Wed, 24 Jan 2007 06:58:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <45B7561C.9000102@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701240657130.9696@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
 <1169625333.4493.16.camel@taijtu> <45B7561C.9000102@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Aubrey Li <aubreylee@gmail.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007, Nick Piggin wrote:

> I can't argue that a smaller pagecache will be subject to a
> higher turnaround given the same workload, but I don't know why
> that would be a good thing.

Neither do I. Wonder why we need this but I keep getting 
these requests. Could we either find a reason for limiting the pagecache 
or get this out of our system for good?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
