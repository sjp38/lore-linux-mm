Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <306020000.1131032193@[10.10.2.4]>
References: <4366C559.5090504@yahoo.com.au>
	 <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au>
	 <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu>
	 <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu>
	 <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu>
	 <1130858580.14475.98.camel@localhost> <20051102084946.GA3930@elte.hu>
	 <436880B8.1050207@yahoo.com.au> <1130923969.15627.11.camel@localhost>
	 <43688B74.20002@yahoo.com.au> <255360000.1130943722@[10.10.2.4]>
	 <4369824E.2020407@yahoo.com.au>  <306020000.1131032193@[10.10.2.4]>
Content-Type: text/plain
Date: Thu, 03 Nov 2005 16:40:21 +0100
Message-Id: <1131032422.2839.8.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <haveblue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-03 at 07:36 -0800, Martin J. Bligh wrote:
> >> Can we quit coming up with specialist hacks for hotplug, and try to solve
> >> the generic problem please? hotplug is NOT the only issue here. Fragmentation
> >> in general is.
> >> 
> > 
> > Not really it isn't. There have been a few cases (e1000 being the main
> > one, and is fixed upstream) where fragmentation in general is a problem.
> > But mostly it is not.
> 
> Sigh. OK, tell me how you're going to fix kernel stacks > 4K please. 

with CONFIG_4KSTACKS :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
