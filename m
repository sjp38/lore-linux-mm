Date: Wed, 26 Jun 2002 18:38:33 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Big memory, no struct page allocation
Message-ID: <20020627013833.GO25360@holomorphy.com>
References: <3D158D1E.1090802@shaolinmicro.com> <20020623085914.GN25360@holomorphy.com> <3D15E9D0.1090209@shaolinmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D15E9D0.1090209@shaolinmicro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
>> Try allocating it at boot-time with the bootmem allocator.

On Sun, Jun 23, 2002 at 11:31:28PM +0800, David Chow wrote:
> Thanks for suggestions, you mean this will allow no struct page or can 
> use memory more than 1GB? Please make clear on direction, I would love 
> to know. Thanks.

On 32-bit machines with 3:1 process address space splits yes.

In this case you're far better off playing games with the highmem
initialization in order to slice the memory out of there and kmap it.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
