Message-ID: <4021A7ED.7070703@cyberone.com.au>
Date: Thu, 05 Feb 2004 13:18:21 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm improvements
References: <Pine.LNX.4.44.0402041026400.24515-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0402041026400.24515-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Rik van Riel wrote:

>On Wed, 4 Feb 2004, Andrew Morton wrote:
>  
>
>>Nick Piggin <piggin@cyberone.com.au> wrote:
>>    
>>
>>> > 2/5: vm-dont-rotate-active-list.patch
>>> >     Nikita's patch to keep more page ordering info in the active list.
>>> >     Also should improve system time due to less useless scanning
>>> >     Helps swapping loads significantly.
>>>      
>>>
>>It bugs me that this improvement is also applicable to 2.4.  if it makes
>>the same improvement there, we're still behind.
>>    
>>
>
>I suspect 2.4 won't see the gains from this, since active/inactive
>list location is hardly relevant for mapped pages there, due to the
>page table scanning algorithm.
>
>  
>

Yeah you're right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
