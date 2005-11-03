Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <311050000.1131040276@[10.10.2.4]>
References: <4366C559.5090504@yahoo.com.au>
	 <Pine.LNX.4.58.0511010137020.29390@skynet><4366D469.2010202@yahoo.com.au>
	 <Pine.LNX.4.58.0511011014060.14884@skynet><20051101135651.GA8502@elte.hu>
	 <1130854224.14475.60.camel@localhost><20051101142959.GA9272@elte.hu>
	 <1130856555.14475.77.camel@localhost><20051101150142.GA10636@elte.hu>
	 <1130858580.14475.98.camel@localhost><20051102084946.GA3930@elte.hu>
	 <436880B8.1050207@yahoo.com.au><1130923969.15627.11.camel@localhost>
	 <43688B74.20002@yahoo.com.au><255360000.1130943722@[10.10.2.4]>
	 <4369824E.2020407@yahoo.com.au> <306020000.1131032193@[10.10.2.4]>
	 <1131032422.2839.8.camel@laptopd505.fenrus.org>
	 <Pine.LNX.4.64.0511030747450.27915@g5.osdl.org>
	 <Pine.LNX.4.58.0511031613560.3571@skynet>
	 <Pine.LNX.4.64.0511030842050.27915@g5.osdl.org>
	 <309420000.1131036740@[10.10.2.4]>
	 <Pine.LNX.4.64.0511030918110.27915@g5.osdl.org>
	 <311050000.1131040276@[10.10.2.4]>
Content-Type: text/plain
Date: Thu, 03 Nov 2005 18:59:45 +0100
Message-Id: <1131040786.2839.18.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <haveblue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-03 at 09:51 -0800, Martin J. Bligh wrote:

> For amusement, let me put in some tritely oversimplified math. For the
> sake of arguement, assume the free watermarks are 8MB or so. Let's assume
> a clean 64-bit system with no zone issues, etc (ie all one zone). 4K pages.
> I'm going to assume random distribution of free pages, which is 
> oversimplified, but I'm trying to demonstrate a general premise, not get
> accurate numbers.

that is VERY over simplified though, given the anti-fragmentation
property of buddy algorithm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
