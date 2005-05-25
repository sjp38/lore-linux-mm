Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j4PIRicE298198
	for <linux-mm@kvack.org>; Wed, 25 May 2005 14:27:44 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4PIRh3f117990
	for <linux-mm@kvack.org>; Wed, 25 May 2005 12:27:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j4PIRh2n024780
	for <linux-mm@kvack.org>; Wed, 25 May 2005 12:27:43 -0600
Message-ID: <4294C39B.1040401@us.ibm.com>
Date: Wed, 25 May 2005 11:27:39 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: NUMA aware slab allocator V3
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com>  <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com>  <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org>  <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net> <1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com> <Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com> <Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com> <428BB05B.6090704@us.ibm.com> <Pine.LNX.4.62.0505181439080.10598@graphe.net> <Pine.LNX.4.62.0505182105310.17811@graphe.net> <428E3497.3080406@us.ibm.com> <Pine.LNX.4.62.0505201210460.390@graphe.net> <428E56EE.4050400@us.ibm.com> <Pine.LNX.4.62.0505241436460.3878@graphe.net> <4293B292.6010301@us.ibm.com> <Pine.LNX.4.62.0505242221340.7191@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0505242221340.7191@graphe.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 24 May 2005, Matthew Dobson wrote:
> 
> 
>>No...  It does compile with that trivial patch, though! :)
>>
>>-mm2 isn't booting on my 32-way x86 box, nor does it boot on my PPC64 box.
>> I figured -mm3 would be out shortly and I'd give the boxes another kick in
>>the pants then...
> 
> 
> Umm.. How does it fail? Any relationship to the slab allocator?

It dies really early om my x86 box.  I'm not 100% sure that it is b/c of
your patches, since it dies so early I get nothing on the console.  Grub
tells me it's loading the kernel image then....  nothing.

-Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
