Date: Fri, 27 Jan 2006 21:08:10 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
Message-Id: <20060127210810.54177d6d.pj@sgi.com>
In-Reply-To: <43DAC222.4060805@us.ibm.com>
References: <20060125161321.647368000@localhost.localdomain>
	<1138233093.27293.1.camel@localhost.localdomain>
	<Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com>
	<43D953C4.5020205@us.ibm.com>
	<Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com>
	<43D95A2E.4020002@us.ibm.com>
	<Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com>
	<43D96633.4080900@us.ibm.com>
	<Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com>
	<43D96A93.9000600@us.ibm.com>
	<20060127025126.c95f8002.pj@sgi.com>
	<43DAC222.4060805@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: clameter@engr.sgi.com, linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew wrote:
> > I too am inclined to prefer the __GFP_CRITICAL approach over this.
> 
> OK.  Chalk one more up for that solution...

I don't think my vote should count for much.  See below.

> This is supposed to be an implementation of Andrea's suggestion.  There are
> no hooks in ANY page_alloc.c code paths.  These patches touch mempool code
> and some slab code, but not any page allocator code.

Yeah - you're right.  I misread your patch set.  Sorry
for wasting your time.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
