Date: Sat, 28 Jun 2003 17:34:05 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.73-mm2
Message-ID: <56960000.1056846845@[10.10.2.4]>
In-Reply-To: <20030628170837.A10514@infradead.org>
References: <20030627202130.066c183b.akpm@digeo.com> <20030628155436.GY20413@holomorphy.com> <20030628170837.A10514@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Christoph Hellwig <hch@infradead.org> wrote (on Saturday, June 28, 2003 17:08:37 +0100):

> On Sat, Jun 28, 2003 at 08:54:36AM -0700, William Lee Irwin III wrote:
>> +config HIGHPMD
>> +	bool "Allocate 2nd-level pagetables from highmem"
>> +	depends on HIGHMEM64G
>> +	help
>> +	  The VM uses one pmd entry for each pagetable page of physical
>> +	  memory allocated. For systems with extreme amounts of highmem,
>> +	  this cannot be tolerated. Setting this option will put
>> +	  userspace 2nd-level pagetables in highmem.
> 
> Does this make sense for !HIGHPTE?  In fact does it make sense to
> carry along HIGHPTE as an option still? ..

Last time I measured it, it had about a 10% overhead in kernel time.
Seems like a good thing to keep as an option to me. Bill said he
had some other code to alleviate the overhead, but I don't think
it's merged ... I'd rather see UKVA (permanently map the pagetables
on a per-process basis) merged before it becomes "not an option" -
that gets rid of all the kmapping.
 
M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
