Date: Sat, 27 Apr 2002 13:38:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: memory exhausted
Message-ID: <20020427203854.GR26092@holomorphy.com>
References: <5.1.0.14.2.20020424145006.00b17cb0@notes.tcindex.com> <Pine.LNX.4.44L.0204242318240.1960-100000@imladris.surriel.com> <20020425025753.GJ26092@holomorphy.com> <3CCAFC69.8090306@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3CCAFC69.8090306@zytor.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Vivian Wang <vivianwang@tcindex.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> This is larger than the virtual address space of i386 machines,
>> but not larger than the physical address space. In principle, an
>> executive taking advantage of 36-bit physical addressing extensions and
>> performing its own memory management on the bare metal could perform an
>> in-core sort on a 36-bit physical addressing -capable 32-bit machine,
>> e.g. i386-style PAE/highmem machines and some 32-bit MIPS machines. A
>> kernel module could also in principle take advantage of the kernel's
>> low-level memory management facilities to perform such an in-core sort.
>> While possible, this is absolutely not recommended.


On Sat, Apr 27, 2002 at 12:30:49PM -0700, H. Peter Anvin wrote:
> Good God, I hope x86-64 catches on soon and kills off this PAE silliness...
> 	-hpa


Taunting me, eh? =)

Well, I did say "absolutely not recommended". 64-bit hardware of
whatever kind is without question a more appropriate solution to these
kinds of issues than such shenanigans anyway, and at this point I'm
more or less sorry I brought that up. And I'll leave the discussion
of what specific lines of hardware are most suitable for other fora. =)


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
