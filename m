Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1GGtLkY014529
	for <linux-mm@kvack.org>; Wed, 16 Feb 2005 11:55:21 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1GGtK40276560
	for <linux-mm@kvack.org>; Wed, 16 Feb 2005 11:55:20 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1GGtKFO001703
	for <linux-mm@kvack.org>; Wed, 16 Feb 2005 11:55:20 -0500
Date: Wed, 16 Feb 2005 08:55:18 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <60510000.1108572918@flay>
In-Reply-To: <20050216160833.GB6604@wotan.suse.de>
References: <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com> <20050216004401.GB8237@wotan.suse.de> <51210000.1108515262@flay> <20050216100229.GB14545@wotan.suse.de> <232990000.1108567298@[10.10.2.4]> <20050216074923.63cf1b6b.pj@sgi.com> <20050216160833.GB6604@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>
Cc: raybry@sgi.com, peterc@gelato.unsw.edu.au, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Wednesday, February 16, 2005 17:08:33 +0100 Andi Kleen <ak@suse.de> wrote:

> On Wed, Feb 16, 2005 at 07:49:23AM -0800, Paul Jackson wrote:
>> Martin wrote:
>> > From reading the code (not actual experiments, yet), it seems like we won't
>> > even wake up the local kswapd until all the nodes are full. And ...
>> 
>> Martin - is there a Cliff Notes summary you could provide of this
>> subthread you and Andi are having?  I got lost somewhere along the way.
> 
> I didn't really have much thread, but as far as I understood it
> Martin just wants kswapd to be a bit more aggressive in making sure
> all nodes always have local memory to allocate from.
> 
> I don't see it as a pressing problem right now, but it may help
> for some memory intensive workloads a bit (see numastat numa_miss output for
> various nodes on how often a "wrong node" fallback happens) 

Yeah - I think I'm just worried that people are proposing a manual rather
than automatic solution to solve fallback issues. We ought to be able
to fix that without tweaking things up the wazoo by hand.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
