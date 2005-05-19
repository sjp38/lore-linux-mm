Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4JJ3I0c644610
	for <linux-mm@kvack.org>; Thu, 19 May 2005 15:03:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JJ3IOG143680
	for <linux-mm@kvack.org>; Thu, 19 May 2005 13:03:18 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4JJ3H0v012740
	for <linux-mm@kvack.org>; Thu, 19 May 2005 13:03:17 -0600
Message-ID: <428CE2EF.803@us.ibm.com>
Date: Thu, 19 May 2005 12:03:11 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V3
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>  <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>  <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>  <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net> <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com> <Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com> <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com> <428BB05B.6090704@us.ibm.com> <Pine.LNX.4.62.0505181439080.10598@graphe.net> <Pine.LNX.4.62.0505182105310.17811@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505182105310.17811@graphe.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 18 May 2005, Christoph Lameter wrote:
> 
>>Fixes to the slab allocator in 2.6.12-rc4-mm2
>>- Remove MAX_NUMNODES check
>>- use for_each_node/cpu
>>- Fix determination of INDEX_AC
> 
> Rats! The whole thing with cpu online and node online is not as easy as I 
> thought. There may be bugs in V3 of the numa slab allocator 
> because offline cpus and offline are not properly handled. Maybe 
> that also contributed to the ppc64 issues. 

Running this test through the "wringer" (aka building/booting on one of our
PPC64 boxen).  I'll let you know if this fixes any problems.


> The earlier patch fails if I boot an x86_64 NUMA kernel on a x86_64 single 
> processor system.
> 
> Here is a revised patch. Would be good if someone could review my use 
> of online_cpu / online_node etc. Is there some way to bring cpus 
> online and offline to test if this really works? Seems that the code in 
> alloc_percpu is suspect even in the old allocator because it may have
> to allocate memory for non present cpus.

I'll look through and see what I can tell you, but I gotta run to a meeting
now. :(

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
