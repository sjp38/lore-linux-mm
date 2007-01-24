Date: Wed, 24 Jan 2007 06:56:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Limit the size of the pagecache
In-Reply-To: <45B75208.90208@linux.vnet.ibm.com>
Message-ID: <Pine.LNX.4.64.0701240655400.9696@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
 <45B75208.90208@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Cc: Aubrey Li <aubreylee@gmail.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Robin Getz <rgetz@blackfin.uclinux.org>, "Henn, erich, Michael" <Michael.Hennerich@analog.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007, Vaidyanathan Srinivasan wrote:

> With your patch, MMAP of a file that will cross the pagecache limit hangs the
> system.  As I mentioned in my previous mail, without subtracting the
> NR_FILE_MAPPED, the reclaim will infinitely try and fail.

Well mapped pages are still pagecache pages.
 
> I have tested your patch with the attached fix on my PPC64 box.

Interesting. What is your reason for wanting to limit the size of the 
pagecache?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
