MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
Date: Tue, 25 Mar 2008 14:29:55 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: larger default page sizes...
In-Reply-To: <20080324.133722.38645342.davem@davemloft.net>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
	<20080321.145712.198736315.davem@davemloft.net>
	<Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
	<20080324.133722.38645342.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

David Miller writes:

> From: Christoph Lameter <clameter@sgi.com>
> Date: Mon, 24 Mar 2008 11:27:06 -0700 (PDT)
> 
> > The move to 64k page size on IA64 is another way that this issue can
> > be addressed though.
> 
> This is such a huge mistake I wish platforms such as powerpc and IA64
> would not make such decisions so lightly.

The performance advantage of using hardware 64k pages is pretty
compelling, on a wide range of programs, and particularly on HPC apps.

> The memory wastage is just rediculious.

Depends on the distribution of file sizes you have.

> I already see several distributions moving to 64K pages for powerpc,
> so I want to nip this in the bud before this monkey-see-monkey-do
> thing gets any more out of hand.

I just tried a kernel compile on a 4.2GHz POWER6 partition with 4
threads (2 cores) and 2GB of RAM, with two kernels.  One was
configured with 4kB pages and the other with 64kB kernels but they
were otherwise identically configured.  Here are the times for the
same kernel compile (total time across all threads, for a fairly
full-featured config):

4kB pages:	444.051s user + 34.406s system time
64kB pages:	419.963s user + 16.869s system time

That's nearly 10% faster with 64kB pages -- on a kernel compile.

Yes, the fragmentation in the page cache can be a pain in some
circumstances, but on the whole I think the performance advantage is
worth that pain, particularly for the sort of applications that people
will tend to be running on RHEL on Power boxes.

Regards,
Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
