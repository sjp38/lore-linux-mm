Date: Fri, 26 Jan 2007 02:27:15 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Limit the size of the pagecache
Message-Id: <20070126022715.afad8716.akpm@osdl.org>
In-Reply-To: <45B6DA8B.7060004@yahoo.com.au>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	<45B6CBD9.80600@yahoo.com.au>
	<Pine.LNX.4.64.0701231908420.6123@schroedinger.engr.sgi.com>
	<6d6a94c50701231951o66487813vcd078fc25e25ffa0@mail.gmail.com>
	<45B6DA8B.7060004@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Aubrey Li <aubreylee@gmail.com>, Christoph Lameter <clameter@sgi.com>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Robin Getz <rgetz@blackfin.uclinux.org>, "Hennerich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007 15:03:23 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> 
> Yeah, it will be failing at order=4, because the allocator won't try
> very hard reclaim pagecache pages at that cutoff point. This needs to
> be fixed in the allocator.

A simple and perhaps sufficient fix for this nommu problem would be to replace
the magic "3" in __alloc_pages() with a tunable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
