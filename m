Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412EC71B.4070308@jp.fujitsu.com>
References: <412DD1AA.8080408@jp.fujitsu.com>
	 <1093535402.2984.11.camel@nighthawk> <412E6CC3.8060908@jp.fujitsu.com>
	 <20040826171840.4a61e80d.akpm@osdl.org> <412E8009.3080508@jp.fujitsu.com>
	 <412EBD22.2090508@jp.fujitsu.com> <1093583072.2984.463.camel@nighthawk>
	 <412EC71B.4070308@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093584691.2984.473.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 22:31:31 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-26 at 22:31, Hiroyuki KAMEZAWA wrote:
> I cannot find suitable one, so I test in microbenchmark calling mmap()
> and munmap(). As you say, real-world workload test is more suitable to
> measure kernel's performance.

Sorry, I thought you were just running a loop with atomic operations
inside of it, not actually exercising the kernel itself.  The test you
described in your mail to Andrew sounds much more useful than what I
thought it was.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
