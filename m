Message-ID: <47BD705A.9020309@bull.net>
Date: Thu, 21 Feb 2008 13:36:42 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [LTP] [PATCH 1/8] Scaling msgmni to the amount of lowmem
References: <20080211141646.948191000@bull.net>	 <20080211141813.354484000@bull.net>	 <20080215215916.8566d337.akpm@linux-foundation.org>	 <47B94D8C.8040605@bull.net>  <47B9835A.3060507@bull.net>	 <1203411055.4612.5.camel@subratamodak.linux.ibm.com>	 <47BB0EDC.5000002@bull.net> <1203459418.7408.39.camel@localhost.localdomain>
In-Reply-To: <1203459418.7408.39.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Helsley <matthltc@us.ibm.com>
Cc: subrata@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, ltp-list@lists.sourceforge.net, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Matt Helsley wrote:
> On Tue, 2008-02-19 at 18:16 +0100, Nadia Derbey wrote:
> 
> <snip>
> 
>>+#define MAX_MSGQUEUES  16      /* MSGMNI as defined in linux/msg.h */
>>+
> 
> 
> It's not quite the maximum anymore, is it? More like the minumum
> maximum ;). A better name might better document what the test is
> actually trying to do.
> 
> One question I have is whether the unpatched test is still valuable.
> Based on my limited knowledge of the test I suspect it's still a correct
> test of message queues. If so, perhaps renaming the old test (so it's
> not confused with a performance regression) and adding your patched
> version is best?
> 

So, here's the new patch based on Matt's points.

Subrata, it has to be applied on top of the original ltp-full-20080131. 
Please tell me if you'd prefer one based on the merged version you've 
got (i.e. with my Tuesday patch applied).

Regards,
Nadia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
