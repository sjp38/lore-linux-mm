Message-ID: <3D076339.1070301@shaolinmicro.com>
Date: Wed, 12 Jun 2002 23:05:29 +0800
From: David Chow <davidchow@shaolinmicro.com>
MIME-Version: 1.0
Subject: Re: slab cache
References: <3D036BBE.4030603@shaolinmicro.com> <20020610095750.B2571@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:

>Hi,
>
>On Sun, Jun 09, 2002 at 10:52:46PM +0800, David Chow wrote:
> 
>
>>I am trying to improve the speed of my fs code. I have a fixed sized 
>>buffer for my fs, I currently use kmalloc for allocation of buffers 
>>greater than 4k, use get_free_page for 4k buffers and vmalloc for large 
>>buffers.
>>
>
>Allocations larger than pagesize always put a higher stress on the VM
>and reduce performance.  Your best bet for top performance will be
>simply to perform no allocations larger than pagesize.  You can use a
>slab cache for those allocations if you want, and that may have some
>advantages depending on the locality of allocations in your code.
>
>Using 4k buffers does not limit your ability to use larger data
>structures --- you can still chain 4k buffers together by creating an
>array of struct page* pointers via which you can access the data.
>
>--Stephen
>
Yes, but for me it is very hard. When doing compression code, most of 
the stuff is not even byte aligned, most of them might be bitwise 
operated, it need very change to existing code. I've already use 
get_free_page to allocate memory that is 4k to avoid some stress to the 
vm, I have no idea about the difference of get_fee_page and the slab 
cache. All my linear buffers stuff is already using array of page 
pointers, if there any benefits for changing them to use slabcache? 
Please advice, thanks.

regards,
David Chow


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
