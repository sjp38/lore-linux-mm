Message-ID: <3CCAFC69.8090306@zytor.com>
Date: Sat, 27 Apr 2002 12:30:49 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: memory exhausted
References: <5.1.0.14.2.20020424145006.00b17cb0@notes.tcindex.com> <Pine.LNX.4.44L.0204242318240.1960-100000@imladris.surriel.com> <20020425025753.GJ26092@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Vivian Wang <vivianwang@tcindex.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> This is larger than the virtual address space of i386 machines,
> but not larger than the physical address space. In principle, an
> executive taking advantage of 36-bit physical addressing extensions and
> performing its own memory management on the bare metal could perform an
> in-core sort on a 36-bit physical addressing -capable 32-bit machine,
> e.g. i386-style PAE/highmem machines and some 32-bit MIPS machines. A
> kernel module could also in principle take advantage of the kernel's
> low-level memory management facilities to perform such an in-core sort.
> While possible, this is absolutely not recommended.
> 

Good God, I hope x86-64 catches on soon and kills off this PAE silliness...

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
