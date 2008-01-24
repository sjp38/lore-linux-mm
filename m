Message-ID: <4798243A.5010708@qumranet.com>
Date: Thu, 24 Jan 2008 07:38:02 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [RFC][PATCH 0/5] Memory merging driver for Linux
References: <4794C2E1.8040607@qumranet.com> <20080123120510.4014e382@bree.surriel.com>
In-Reply-To: <20080123120510.4014e382@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Izik Eidus <izike@qumranet.com>, kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Mon, 21 Jan 2008 18:05:53 +0200
> Izik Eidus <izike@qumranet.com> wrote:
>
>   
>> i added 2 new functions to the kernel
>> one:
>> page_wrprotect() make the page as read only by setting the ptes point to
>> it as read only.
>> second:
>> replace_page() - replace the pte mapping related to vm area between two 
>> pages
>>     
>
> How will this work on CPUs with nested paging support, where the
> CPU does the guest -> physical address translation?  (opposed to
> having shadow page tables)
>
>   

Nested page tables are very similar to real-mode shadow paging: both 
translate guest physical addresses to host physical addreses.

In any case, the merge driver is oblivious to the paging method used, it 
works at the Linux pte level and relies on mmu notifiers to keep 
everything in sync.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
