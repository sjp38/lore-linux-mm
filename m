Message-ID: <446A978C.3000800@yahoo.com.au>
Date: Wed, 17 May 2006 13:25:00 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 00/14] remap_file_pages protection support
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <200605030225.54598.blaisorblade@yahoo.it> <445CC949.7050900@redhat.com> <445D75EB.5030909@yahoo.com.au> <4465E981.60302@yahoo.com.au> <20060513181945.GC9612@goober> <4469D3F8.8020305@yahoo.com.au> <20060516135135.GA28995@rhlx01.fht-esslingen.de> <20060516163111.GK9612@goober> <20060516164743.GA23893@rhlx01.fht-esslingen.de>
In-Reply-To: <20060516164743.GA23893@rhlx01.fht-esslingen.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Cc: Valerie Henson <val_henson@linux.intel.com>, Ulrich Drepper <drepper@redhat.com>, Blaisorblade <blaisorblade@yahoo.it>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

Andreas Mohr wrote:

>Hi,
>
>On Tue, May 16, 2006 at 09:31:12AM -0700, Valerie Henson wrote:
>
>>On Tue, May 16, 2006 at 03:51:35PM +0200, Andreas Mohr wrote:
>>
>>>I cannot offer much other than some random confirmation that from my own
>>>oprofiling, whatever I did (often running a load test script consisting of
>>>launching 30 big apps at the same time), find_vma basically always showed up
>>>very prominently in the list of vmlinux-based code (always ranking within the
>>>top 4 or 5 kernel hotspots, such as timer interrupts, ACPI idle I/O etc.pp.).
>>>call-tracing showed it originating from mmap syscalls etc., and AFAIR quite
>>>some find_vma activity from oprofile itself.
>>>
>>This is important: Which kernel?
>>
>
>I had some traces still showing find_vma prominently during a profiling run
>just yesterday, with a very fresh 2.6.17-rc4-ck1 (IOW, basically 2.6.17-rc4).
>I added some cache prefetching in the list traversal a while ago, and IIRC
>that improved profiling times there, but cache prefetching is very often
>a bandaid in search for a real solution: a better data-handling algorithm.
>

If you want to try out the patch and see what it does for you, that would be
interesting. I'll repost a slightly cleaned up version in a couple of hours.

Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
