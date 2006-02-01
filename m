Date: Wed, 01 Feb 2006 15:16:02 +0900 (JST)
Message-Id: <20060201.151602.71086465.taka@valinux.co.jp>
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
 controller
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20060201053958.CE35B74035@sv1.valinux.co.jp>
References: <20060131023000.7915.71955.sendpatchset@debian>
	<1138762698.3938.16.camel@localhost.localdomain>
	<20060201053958.CE35B74035@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: kurosawa@valinux.co.jp, ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chandra,

>You are welcome.  Thanks for the comments.
>
>> I have few questions:
>>  - how are shared pages handled ?
>
>Shared pages are accounted to the class that a task in it allocate 
>the pages.  This behavior is different from the memory resource 
>controller in CKRM.
>
>>  - what is the plan to support "limit" ?
>
>To be honest, I don't have any specific idea to support "limit" currently.
>Probably the userspace daemon that enlarge "guarantee" to the specified
>"limit" might support the "limit", because "guarantee" in the pzone based 
>memory resource controller also works as "limit".

I think that this should be placed outside of Kurosawa's controller.
That would be a kernel thread between CKRM API and the controller,
which collects statistics about pzones to change the size of them
between "guarantee" and "limit". An userspace daemon would be also OK.

To separate balancing pzones code from VM will keep the code simple.

>>  - can you provide more information in stats ?
>
>Ok, I'll do that.
>
>>  - is it designed to work with cpumeter alone (i.e without ckrm) ?
>
>Maybe it works with cpumeter.
>
>> comment/suggestion:
>>  - IMO, moving pages from a class at time of reclassification would be
>>    the right thing to do. May be we have to add a pointer to Chris patch
>>    and make sure it works as we expect.
>> 
>>  - instead of adding the pseudo zone related code to the core memory
>>    files, you can put them in a separate file.
>
>That's right.  But I guess that several static functions in 
>mm/page_alloc.c would need to be exported.
>
>>  - Documentation on how to configure and use it would be good.
>
>I think so too.  I'll write some documents.

Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
