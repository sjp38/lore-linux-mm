Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A59BB6B0070
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 08:20:15 -0400 (EDT)
Received: by mail-wg0-f71.google.com with SMTP id es5so353521wgb.2
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 05:20:14 -0700 (PDT)
Message-ID: <5087DCF8.6080205@ravellosystems.com>
Date: Wed, 24 Oct 2012 14:20:08 +0200
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: ksm questions
References: <5087CED1.2030307@gmail.com> <5087D50D.8000101@ravellosystems.com> <5087D817.7070106@gmail.com> <5087D8E3.6090900@ravellosystems.com> <5087DC00.6070408@gmail.com>
In-Reply-To: <5087DC00.6070408@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>

On 10/24/2012 02:16 PM, Ni zhan Chen wrote:
> On 10/24/2012 08:02 PM, Izik Eidus wrote:
>> On 10/24/2012 01:59 PM, Ni zhan Chen wrote:
>>> On 10/24/2012 07:46 PM, Izik Eidus wrote:
>>>> On 10/24/2012 01:19 PM, Ni zhan Chen wrote:
>>>>> Hi all,
>>>>>
>>>>> I have some questions about ksm.
>>>>>
>>>>> 1) khugepaged default nice value is 19, but ksmd default nice 
>>>>> value is 5, why this big different?
>>>>> 2) why ksm doesn't support pagecache and tmpfs now? What's the 
>>>>> bottleneck?
>>>>> 3) ksm kernel doc said that "KSM only merges anonymous(private) 
>>>>> pages, never pagecache(file) pages". But where judege it should be 
>>>>> private?
>>>>> 4) ksm kernel doc said that "To avoid the instability and the 
>>>>> resulting false negatives to be permanent, KSM re-initializes the 
>>>>> unstable tree root node to an empty tree, at every KSM pass." But 
>>>>> I can't find where re-initializes the unstable tree, could you 
>>>>> explain me?
>>>>
>>>>
>>>> in scan_get_next_rmap_item(), if (slot == &ksm_mm_head) then we do 
>>>> root_unstable_tree = RB_ROOT; this will result in 
>>>> root_unstable_tree being empty.
>>>
>>> thanks Izik, what about the other three questions?
>>
>> Question number 2 is beacuse it is forced to work with anonymous 
>> pages, about question 3 - I will have to remember why from the very 
>> begining I wrote it to support only anonymous pages (few years have 
>> been passed), maybe Andrea/Huge have it more hot in their heads?
>
> The initialize goal of design ksm is for virtualization, but now it 
> also can be used for other apps. So can it also support tmpfs or 
> pagecache in the future?

Talking from far memory, I remember it was easier/cleaner to only 
support anonymous pages, until Andrea/Huge won`t remind us why I can`t 
answer this
(Maybe later I will have some time to read a little bit the code again 
and to remember what is going on in linux VM...)

>
>>
>>>
>>>>
>>>>>
>>>>> Thanks in advance. :-)
>>>>>
>>>>> Regards,
>>>>> Chen
>>>>>
>>>>
>>>>
>>>
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
