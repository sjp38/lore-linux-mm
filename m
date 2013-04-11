Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 575046B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 08:51:47 -0400 (EDT)
Message-ID: <5166B1DF.8070504@hitachi.com>
Date: Thu, 11 Apr 2013 21:51:43 +0900
From: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
MIME-Version: 1.0
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
References: <51662D5B.3050001@hitachi.com> <516633BB.40307@gmail.com>
In-Reply-To: <516633BB.40307@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

(2013/04/11 12:53), Simon Jeons wrote:
> One question against mce instead of the patchset. ;-)
> 
> When check memory is bad? Before memory access? Is there a process scan it period?

Hi Simon-san,

Yes, there is a process to scan memory periodically.

At Intel Nehalem-EX and CPUs after Nehalem-EX generation, MCA recovery
is supported. MCA recovery provides error detection and isolation
features to work together with OS.
One of the MCA Recovery features is Memory Scrubbing. It periodically
checks memory in the background of OS.

If Memory Scrubbing find an uncorrectable error on a memory before
OS accesses the memory bit, MCA recovery notifies SRAO error into OS 
and OS handles the SRAO error using hwpoison function.

Regards,
Mitsuhiro Tanino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
