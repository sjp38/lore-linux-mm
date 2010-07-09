Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EFB99600922
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 18:02:28 -0400 (EDT)
Message-ID: <4C379C5A.8070202@redhat.com>
Date: Fri, 09 Jul 2010 18:02:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix swapin race condition
References: <20100709002322.GO6197@random.random> <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.1007091242430.8201@tigran.mtv.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

On 07/09/2010 04:32 PM, Hugh Dickins wrote:

>>   	struct anon_vma *anon_vma = page_anon_vma(page);
>>
>> -	if (!anon_vma ||
>> -	    (anon_vma->root == vma->anon_vma->root&&
>> -	     page->index == linear_page_index(vma, address)))
>> -		return page;
>> -
>> -	return ksm_does_need_to_copy(page, vma, address);
>> +	return anon_vma&&
>> +		(anon_vma->root != vma->anon_vma->root ||
>> +		 page->index != linear_page_index(vma, address));
>>   }
>
> Hiding in here is a bigger question than your concern:
> are these tests right since Rik refactored the anon_vmas?
> I just don't know, but hope you and Rik can answer.

Yes, this bit is correct.  Andrea and I have gone over
this in detail a few weeks ago :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
