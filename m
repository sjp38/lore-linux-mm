Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C321C6B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 02:49:32 -0500 (EST)
Received: by pxi26 with SMTP id 26so817106pxi.1
        for <linux-mm@kvack.org>; Wed, 03 Mar 2010 23:49:31 -0800 (PST)
Message-ID: <4B8F65CE.5090501@gmail.com>
Date: Thu, 04 Mar 2010 15:48:30 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] swapfile : fix the wrong return value
References: <1267501102-24190-1-git-send-email-shijie8@gmail.com> <alpine.LSU.2.00.1003040029210.28735@sister.anvils> <4B8F5A82.2030805@gmail.com> <alpine.LSU.2.00.1003040706400.3894@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1003040706400.3894@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> Yes.  Well, we are debating the likelihoods of corruption in different memory
> areas here.  I answer "Yes" because the swap entry involved in try_to_unmap_one()
> comes from page->private when PageSwapCache is set (and the page is locked):
> it requires either an mm bug, or corruption of struct page, for that swap entry
> to be invalid for duplication.  Memory corruption of entries in a user page
> table seems to have been a more common case, whether because of single-bit memory
> errors, or use-after-free bugs: that's the case which copy_one_pte() might meet.
>    
:), ok, thanks a lot for your kind explanations.
>
>    
>> For the sake of the stability of the system, I perfer to export all the error
>> value, and check it carefully.
>>      
> But we were happy with void swap_duplicate() for many years.
> If I wanted to make a further change, it would rather be to remove those
> error returns from __swap_duplicate() which are not actually made use of.
>
> Hugh
>
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
