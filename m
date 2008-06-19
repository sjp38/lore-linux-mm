Date: Thu, 19 Jun 2008 18:16:44 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: 2.6.26-rc5-mm3: BUG large value for HugePages_Rsvd
Message-ID: <20080619171644.GC13275@shadowen.org>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <485A8903.9030808@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <485A8903.9030808@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 19, 2008 at 11:27:47AM -0500, Jon Tollefson wrote:
> After running some of the libhugetlbfs tests the value for
> /proc/meminfo/HugePages_Rsvd becomes really large.  It looks like it has
> wrapped backwards from zero.
> Below is the sequence I used to run one of the tests that causes this;
> the tests passes for what it is intended to test but leaves a large
> value for reserved pages and that seemed strange to me.
> test run on ppc64 with 16M huge pages

Yes Adam reported that here yesterday, he found it in his hugetlfs testing.
I have done some investigation on it and it is being triggered by a bug in
the private reservation tracking patches.  It is triggered by the hugetlb
test which causes some complex vma splits to occur on a private mapping.

I believe I have the underlying problem nailed and do have some nearly
complete patches for this and they should be in a postable state by
tommorrow.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
