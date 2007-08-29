Date: Wed, 29 Aug 2007 23:31:54 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC:PATCH 00/07] VM File Tails
Message-ID: <20070829213154.GB29635@lazybastard.org>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 August 2007 16:53:25 -0400, Dave Kleikamp wrote:
>
> - benchmark!

I'd love to know how much difference this makes.  Basically four
numbers:
- number of address spaces
- bytes allocated for file tails
- number of pages allocated for non-tail storage
- number of pages allocated for tail storage

With those it should be possible to calculate how much is saved by using
tail and how much is wasted by having both tails and a page.  Putting
this in relation to the total amount of data in page cache is
interesting as well.

While not as decisive as benchmarks it may give some indication why
certain workloads benefit or suffer.

JA?rn

-- 
The rabbit runs faster than the fox, because the rabbit is rinning for
his life while the fox is only running for his dinner.
-- Aesop

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
