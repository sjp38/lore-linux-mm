Date: Wed, 26 Nov 2003 05:25:34 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test10-mm1
Message-ID: <20031126132534.GO8039@holomorphy.com>
References: <20031125211518.6f656d73.akpm@osdl.org> <20031126085123.A1952@infradead.org> <20031126044251.3b8309c1.akpm@osdl.org> <20031126130936.A5275@infradead.org> <20031126132144.GN8039@holomorphy.com> <20031126132311.B5477@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031126132311.B5477@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 26, 2003 at 05:21:44AM -0800, William Lee Irwin III wrote:
>> I'm not one to toe the party line, but this really does seem innocuous
>> and of more general use than GPFS. I'd say walking pagetables directly
>> in fs and/or device drivers is more invasive wrt. VM internals than
>> calling a well-established procedure, but that's just me.

On Wed, Nov 26, 2003 at 01:23:11PM +0000, Christoph Hellwig wrote:
> GPFS is doing all that, too of course.  Take a look at their glue code
> at oss.software.ibm.com (and take a barf-bag with you while you're at
> it..)

I've got a relatively concrete notion GPFS is not particularly
meritorious. =( Perhaps invalid_mmap_range() would be better off with
a poster child that's taken a bath sometime in its life...


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
