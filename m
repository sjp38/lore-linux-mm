Date: Wed, 24 Apr 2002 19:57:53 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: memory exhausted
Message-ID: <20020425025753.GJ26092@holomorphy.com>
References: <5.1.0.14.2.20020424145006.00b17cb0@notes.tcindex.com> <Pine.LNX.4.44L.0204242318240.1960-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0204242318240.1960-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Vivian Wang <vivianwang@tcindex.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2002 at 11:19:50PM -0300, Rik van Riel wrote:
> [mailing list address corrected ... won't people ever learn to read ?]

On Wed, 24 Apr 2002, Vivian Wang wrote:
>> I try to sort my 11 GB file, but I got message about memory exhausted.
>> I used the command like this:
>> sort -u file1 -o file2
>> Is this correct?

On Wed, Apr 24, 2002 at 11:19:50PM -0300, Rik van Riel wrote:
> Yes, sort only has a maximum of 3 GB of virtual address space so
> it will never be able to load the whole 11 GB file into memory.

This is larger than the virtual address space of i386 machines,
but not larger than the physical address space. In principle, an
executive taking advantage of 36-bit physical addressing extensions and
performing its own memory management on the bare metal could perform an
in-core sort on a 36-bit physical addressing -capable 32-bit machine,
e.g. i386-style PAE/highmem machines and some 32-bit MIPS machines. A
kernel module could also in principle take advantage of the kernel's
low-level memory management facilities to perform such an in-core sort.
While possible, this is absolutely not recommended.


On Wed, 24 Apr 2002, Vivian Wang wrote:
>> What I should do?

On Wed, Apr 24, 2002 at 11:19:50PM -0300, Rik van Riel wrote:
> You could either write your own sort program that doesn't need
> to have the whole file loaded or you could use a 64 bit machine
> with at least 11 GB of available virtual memory, probably the
> double...
> regards,
> Rik

It's doubtful the above "solutions" I mentioned above are practical for
your purposes unless you are under the most extreme duress and have
access to uncommon hardware. I suggest polyphase merge sorting or any
of the various algorithms recommended in Donald E. Knuth's "The Art of
Computer Programming", specifically its chapter on external sorting,
which I'm willing to discuss and assist in implementations of off-list.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
