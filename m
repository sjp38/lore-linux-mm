Message-ID: <422D8F2A.4010002@jp.fujitsu.com>
Date: Tue, 08 Mar 2005 20:40:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2/2 Prezeroing large blocks of pages during allocation
 Version 4
References: <20050307194021.E6A86E594@skynet.csn.ul.ie> <422D42BF.4060506@jp.fujitsu.com> <Pine.LNX.4.58.0503081012270.30439@skynet>
In-Reply-To: <Pine.LNX.4.58.0503081012270.30439@skynet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

>>>      
>>>
>>Now, 5bits per  MAX_ORDER pages.
>>I think it is simpler to use "char[]" for representing type of  memory alloc
>>type than bitmap.
>>
>>    
>>
>
>Possibly, but it would also use up that bit more space. That map could be
>condensed to 3 bits but would make it that bit (no pun) more complex and
>difficult to merge. On the other hand, it would be faster to use a char[]
>as it would be an array-index lookup to get a pageblock type rather than a
>number of bit operations.
>
>So, it depends on what people know to be better in general because I have
>not measured it to know for a fact. Is it better to use char[] and use
>array indexes rather than bit operations or is it better to leave it as a
>bitmap and condense it later when things have settled down?
>  
>
Hmm, Okay, I'll wait for condensed version.
BTW, in space consumption/cache view,  does using bitmap have  real 
benefit   ?

Thanks
-- Kame <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
