Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4ILFD6R028640
	for <linux-mm@kvack.org>; Wed, 18 May 2005 17:15:13 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4ILFCkv114664
	for <linux-mm@kvack.org>; Wed, 18 May 2005 17:15:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4ILFCuH025637
	for <linux-mm@kvack.org>; Wed, 18 May 2005 17:15:12 -0400
Message-ID: <428BB05B.6090704@us.ibm.com>
Date: Wed, 18 May 2005 14:15:07 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V3
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>  <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>  <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>  <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net> <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com> <Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com> <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Christoph Lameter <christoph@lameter.com>, Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <mbligh@mbligh.org>, Jesse Barnes <jbarnes@virtuousgeek.org>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, shai@scalex86.org, steiner@sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 18 May 2005, Matthew Dobson wrote:
> 
> 
>>Thanks!  I just looked at V2 & V3 of the patch and saw some open-coded
>>loops.  I may have missed a later version of the patch which has fixes.
>>Feel free to CC me on future versions of the patch...
> 
> 
> I will when I get everything together. The hold up at the moment is that 
> Martin has found a boot failure with the new slab allocator on ppc64 that 
> I am unable to explain.
>  
> Strangely, the panic is in the page allocator. I have no means of 
> testing since I do not have a ppc64 system available. Could you help me 
> figure out what is going on?

I can't promise anything, but if you send me the latest version of your
patch (preferably with the loops fixed to eliminate the possibility of it
accessing an unavailable/unusable node), I can build & boot it on a PPC64
box and see what happens.

-Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
