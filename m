Date: Wed, 21 Mar 2007 15:26:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: pagetable_ops: Hugetlb character device example
Message-ID: <20070321222659.GJ2986@holomorphy.com>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <1174506228.21684.41.camel@localhost.localdomain> <200703211951.l2LJpVPS020364@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200703211951.l2LJpVPS020364@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Mar 2007 14:43:48 CDT, Adam Litke said:
>> The main reason I am advocating a set of pagetable_operations is to
>> enable the development of a new hugetlb interface.

On Wed, Mar 21, 2007 at 03:51:31PM -0400, Valdis.Kletnieks@vt.edu wrote:
> Do you have an exit strategy for the *old* interface?

Hello.

My exit strategy was to make hugetlbfs an alias for ramfs when ramfs
acquired the necessary functionality until expand-on-mmap() was merged.
That would've allowed rm -rf fs/hugetlbfs/ outright. A compatibility
wrapper for expand-on-mmap() around ramfs once ramfs acquires the
necessary functionality is now the exit strategy.

Given current opinions on general multiple pagesize support, by means of
which the ramfs functionality is/was intended to be implemented, that
time may well be "never."

Character device analogues of /dev/zero are not replacements for the
filesystem. Few or no transitions of existing users to such are
possible. It primarily enables new users who really need anonymous
hugetlb, such as numerical applications. The need for a filesystem
namespace and persisting across process creation and destruction will
not be eliminated by character devices.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
