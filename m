Date: Fri, 25 Apr 2003 16:58:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: TASK_UNMAPPED_BASE & stack location
Message-ID: <20030425235843.GU8978@holomorphy.com>
References: <459930000.1051302738@[10.10.2.4]> <3EA9CA25.E140A02C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EA9CA25.E140A02C@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: badari <pbadari@us.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>, Andrew Morton <akpm@digeo.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 25, 2003 at 04:52:05PM -0700, badari wrote:
> Only problem with moving TASK_UNMAPPED_BASE right above
> text would be - limiting the malloc() space. malloc() is clever enough
> to mmap() and do the right thing. Once I moved TASK_UNMAPPED_BASE
> to 0x10000000 and I could not run some of the programs with large
> data segments.
> Moving stacks below text would be tricky. pthread library knows
> the placement of stack. It uses this to distinguish between
> threads and pthreads manager.
> I don't know what other librarys/apps depend on this kind of stuff.

STACK_TOP is easy to change to see what goes wrong; it's a single
#define in include/asm-i386/a.out.h

Someone should spin it up and see how well pthreads copes.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
