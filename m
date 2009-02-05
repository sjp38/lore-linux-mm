Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E5046B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 07:24:18 -0500 (EST)
Message-ID: <498ADA5D.90201@virident.com>
Date: Thu, 05 Feb 2009 17:53:57 +0530
From: Swamy Gowda <swamy@virident.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] release mmap_sem before starting migration (Was
 Re: Need to take mmap_sem lock in move_pages.
References: <28631E6913C8074E95A698E8AC93D091B21561@caexch1.virident.info>	<20090204183600.f41e8b7e.kamezawa.hiroyu@jp.fujitsu.com>	<20090204184028.09a4bbae.kamezawa.hiroyu@jp.fujitsu.com>	<20090204185501.837ff5d6.kamezawa.hiroyu@jp.fujitsu.com>	<alpine.DEB.1.10.0902041037150.19633@qirst.com> <20090205101503.b1fd7df6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090205101503.b1fd7df6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, Brice.Goglin@inria.fr, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 4 Feb 2009 10:39:19 -0500 (EST)
> Christoph Lameter <cl@linux-foundation.org> wrote:
>
>> On Wed, 4 Feb 2009, KAMEZAWA Hiroyuki wrote:
>>
>> > mmap_sem can be released after page table walk ends.
>>
>> No. read lock on mmap_sem must be held since the migrate functions
>> manipulate page table entries. Concurrent large scale changes to the 
>> page
>> tables (splitting vmas, remapping etc) must not be possible.
>>
> Just for clarification:
>
> 1. changes in page table is not problem from the viewpoint of kernel.
>   (means no panic, no leak,...)
> 2. But this loses "atomic" aspect of migration and will allow unexpected
>   behaviors.
>   (means the page-mapping status after sys_move may not be what user 
> expects.)
>
>
> Thanks,
> -Kame
>
>
But I can't understand how user can see different page->mapping , since 
new page->mapping still holds the anon_vma pointer which should still 
contain the changes in the vma list( due to split vma etc). But, 
considering it as a problem how is it avoided in case of hotremove?

 

--Swamy


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
