Date: Fri, 06 Feb 2004 07:49:38 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [Bugme-new] [Bug 2019] New: Bug from the mm subsystem	involving X  (fwd)
Message-ID: <5450000.1076082574@[10.10.2.4]>
In-Reply-To: <1076061476.27855.1144.camel@nighthawk>
References: <51080000.1075936626@flay> <Pine.LNX.4.58.0402041539470.2086@home.osdl.org><60330000.1075939958@flay> <64260000.1075941399@flay><Pine.LNX.4.58.0402041639420.2086@home.osdl.org> <20040204165620.3d608798.akpm@osdl.org> <Pine.LNX.4.58.0402041719300.2086@home.osdl.org> <1075946211.13163.18962.camel@dyn318004bld.beaverton.ibm.com> <Pine.LNX.4.58.0402041800320.2086@home.osdl.org> <98220000.1076051821@[10.10.2.4]> <1076061476.27855.1144.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Keith Mannthey <kmannth@us.ibm.com>, Andrew Morton <akpm@osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> +#ifdef CONFIG_NUMA
>> +	#ifdef CONFIG_X86_NUMAQ
>> +		#include <asm/numaq.h>
>> +	#else	/* summit or generic arch */
>> +		#include <asm/srat.h>
>> +	#endif
>> +#else /* !CONFIG_NUMA */
>> +	#define get_memcfg_numa get_memcfg_numa_flat
>> +	#define get_zholes_size(n) (0)
>> +#endif /* CONFIG_NUMA */
> 
> We ran into a bug with #ifdefs like this before.  It was fixed in some
> of the code that you're trying to remove.

What bug?
 
> It's not safe to assume that NUMA && !NUMAQ means SUMMIT.  Remember the
> linking errors we got when we turned CONFIG_NUMA on with the regular PC
> config?  The generic arch wasn't a problem because it sets
> CONFIG_X86_SUMMIT and compiles in the summit code, but the regular PC
> code doesn't.  
> 
> Also, I don't think we need the #ifdef CONFIG_NUMA around the whole
> block.  How about something like this?

If you want to go change it, and test the crap out of it for 3 months on
a variety of platforms, then go for it. What's here works, and is well
tested - I'm sticking with it, unless you can point out a specific case
where it's wrong.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
