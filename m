Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1G0sOLL016257
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 19:54:24 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1G0sOfN225578
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 19:54:24 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1G0sOGZ027168
	for <linux-mm@kvack.org>; Tue, 15 Feb 2005 19:54:24 -0500
Date: Tue, 15 Feb 2005 16:54:23 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <51210000.1108515262@flay>
In-Reply-To: <20050216004401.GB8237@wotan.suse.de>
References: <1108407043.6154.49.camel@localhost> <20050214220148.GA11832@lnx-holt.americas.sgi.com> <20050215074906.01439d4e.pj@sgi.com> <20050215162135.GA22646@lnx-holt.americas.sgi.com> <20050215083529.2f80c294.pj@sgi.com> <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com> <20050216004401.GB8237@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, February 16, 2005 01:44:01 +0100 Andi Kleen <ak@suse.de> wrote:

>> SGI had code in IRIX to do that kind of thing (automatically move a page to
>> the node where most of the references were coming from).  Never worked very 
>> well, I have been told.   So our bias is away from such "automatic" page
>> migration schemes and toward "manual" methods driven either by a user
>> command or a user-level program such as a batch scheduler.
> 
> I tried something similar too (scheduling a task to the node with most of 
> its memory) and it also never worked very well.

I'm talking about doing it the other way around though - just allocating
the memory local to the task, not bringing the task to the memory.

If kswapd would keep up, we'd be OK - it should keep enough memory free
on the local node that we'd always get local free pages for the new bits.
If we go into fallback and immediate reclaim from __alloc_pages, then I
think everything starts to fall apart.

Perhaps we should just make sure most of the reclaim is being done from
kswapd - we're trying to work out exactly how much of the reclaim happens
where right at the moment.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
