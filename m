Date: Thu, 04 Oct 2007 14:00:38 -0700 (PDT)
Message-Id: <20071004.140038.126762674.davem@davemloft.net>
Subject: Re: [ANNOUNCE] ebizzy 0.2 released
From: David Miller <davem@davemloft.net>
In-Reply-To: <20071004204201.GB6090@rainbow>
References: <20070823010626.GC11402@rainbow>
	<20070930.172703.79041329.davem@davemloft.net>
	<20071004204201.GB6090@rainbow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Valerie Henson <val@nmt.edu>
Date: Thu, 4 Oct 2007 14:42:01 -0600
Return-Path: <owner-linux-mm@kvack.org>
To: val@nmt.edu
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rrbranco@br.ibm.com, twichell@us.ibm.com, ycai@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Ebizzy is based on a real web application server and does do things
> that are fairly common in such applications (multithreaded memory
> allocation and memory access), but it ignores networking for two
> reasons: the network stack was not the bottleneck for this workload,
> the VM was, and really good network benchmarks already exist. :)
> ebizzy is not useful to networking (or file systems) developer, but it
> has been used to improve malloc() behavior in glibc and to test VMA
> handling optimizations.

Thanks for clarifying all of this Valerie.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
