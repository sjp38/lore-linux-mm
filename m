Message-ID: <4245CC80.10306@osdl.org>
Date: Sat, 26 Mar 2005 12:56:32 -0800
From: "Randy.Dunlap" <rddunlap@osdl.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/4] create mm/Kconfig for arch-independent memory
 options
References: <E1DEwlP-0006BQ-00@kernel.beaverton.ibm.com>	 <4244D068.3080900@osdl.org> <1111863649.9691.100.camel@localhost>
In-Reply-To: <1111863649.9691.100.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Fri, 2005-03-25 at 19:00 -0800, Randy.Dunlap wrote:
> ...
> 
>>>+config DISCONTIGMEM
>>>+	bool "Discontigious Memory"
>>>+	depends on ARCH_DISCONTIGMEM_ENABLE
>>>+	help
>>>+	  If unsure, choose this option over "Sparse Memory".
>>
>>Same question....
> 
> 
> It's in the third patch in the series.  They were all together at one
> point and I was trying to be lazy, but you caught me :)

I wasn't trying to catch you, but I've already looked at
all 4 patches in the series and I still can't find an
option that is labeled/described as "Sparse Memory"....
The word "sparse" isn't even in patch 3/4... maybe
there is something missing?

-- 
~Randy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
