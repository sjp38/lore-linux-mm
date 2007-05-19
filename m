Message-ID: <464F1B21.8020408@shadowen.org>
Date: Sat, 19 May 2007 16:43:29 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [rfc] increase struct page size?! (now sparsemem vmemmap)
References: <20070518040854.GA15654@wotan.suse.de> <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com> <20070519012530.GB15569@wotan.suse.de> <Pine.LNX.4.64.0705181901130.14521@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705181901130.14521@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 19 May 2007, Nick Piggin wrote:
> 
>> Hugh points out that we should make _count and _mapcount atomic_long_t's,
>> which would probably be a better use of the space once your vmemmap goes
>> in.
> 
> Well Andy was going to merge it:
> 
> http://marc.info/?l=linux-kernel&m=117620162415620&w=2
> 
> Andy when are we going to get the vmemmap patches into sparsemem?

Sorry this has been backed up with all the too-ing and fro-ing on other
things.  I am just cleaning up the next round which includes feedback
from wli and first stab at PPC64 support.  Should be out monday for review.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
