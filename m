Received: from m2.gw.fujitsu.co.jp ([10.0.50.72]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i980kAR6023070 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 09:46:10 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m2.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i980k9f1021448 for <linux-mm@kvack.org>; Fri, 8 Oct 2004 09:46:09 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A23861F723E
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 09:46:09 +0900 (JST)
Received: from fjmail502.fjmail.jp.fujitsu.com (fjmail502-0.fjmail.jp.fujitsu.com [10.59.80.98])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B9A51F723C
	for <linux-mm@kvack.org>; Fri,  8 Oct 2004 09:46:09 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail502.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5800D0VQ4RD0@fjmail502.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Fri,  8 Oct 2004 09:46:05 +0900 (JST)
Date: Fri, 08 Oct 2004 09:51:40 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH]  no buddy bitmap patch : intro and includes [0/2]
In-reply-to: <1260090000.1097164623@[10.10.2.4]>
Message-id: <4165E49C.6080604@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
References: <D36CE1FCEFD3524B81CA12C6FE5BCAB007ED31D6@fmsmsx406.amr.corp.intel.com>
 <1097163578.3625.43.camel@localhost> <1260090000.1097164623@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Matthew E Tolentino <matthew.e.tolentino@intel.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, Andrew Morton <akpm@osdl.org>, William Lee Irwin III <wli@holomorphy.com>, "Luck, Tony" <tony.luck@intel.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave McCracken <dmccr@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
 >>>>What was the purpose behind this, again? Sorry, has been too long since
 >>>>I last looked.

>>On Thu, 2004-10-07 at 08:03, Tolentino, Matthew E wrote:
>>
>>For one, it avoids the otherwise requisite resizing of the bitmaps=20
>>during memory hotplug operations...
>>

 >> Dave McCracken wrote:
>> The memory allocator bitmaps are the main remaining reason we need the
>> concept of linear memory.  If we can get rid of them, it's one step closer
>> to managing memory as a set of sections.

 >>--Dave Hansen <haveblue@us.ibm.com> wrote (on Thursday, October 07, 2004 08:39:38 -0700)
>>It also simplifies the nonlinear implementation.  The whole reason we
>>had the lpfn (Linear) stuff was so that the bitmaps could represent a
>>sparse physical address space in a much more linear fashion.  With no
>>bitmaps, this isn't an issue, and gets rid of a lot of code, and a
>>*huge* source of bugs where lpfns and pfns are confused for each other. 
> 
> 
> Makese sense on both counts. Would be nice to add the justification to 
> the changelog ;-)
> 

It seems all I should answer is already answered.
Thank you all.

I'll add the purpose to the changelog.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

> M.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
