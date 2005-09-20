Message-ID: <432F97E1.4080805@ccoss.com.cn>
Date: Tue, 20 Sep 2005 13:02:25 +0800
From: liyu <liyu@ccoss.com.cn>
MIME-Version: 1.0
Subject: Re: [Question] How to understand Clock-Pro algorithm?
References: <432F7DD5.6050204@ccoss.com.cn> <1127188898.3130.52.camel@moon.c3.lanl.gov>
In-Reply-To: <1127188898.3130.52.camel@moon.c3.lanl.gov>
Content-Type: text/plain; charset=gb18030; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Song Jiang <sjiang@lanl.gov>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi:

    OOh, the original author here! Thanks a lot.

    Let's assume Mn is the total number of non-resident pages in follow 
words.

    Nod, 'M=Mh+Mc' and 'Mc+Mn' < 2M are always true.

    Have this implied that Mn is alway less than M? I think so.

    but if "Once the number exceeds M the memory size in number of pages,
we terminted the test period of the cold page pointed to by HAND-test."

    If Mn is alway less than M, when we move to HAND-test?

    Or, my view have error.

    I doublt on this, in fact.

    Good luck.

                                                                    Liyu


Song Jiang Wrote:

>On Mon, 2005-09-19 at 21:11, liyu wrote:
>
>  
>
>>    My question is out:As this paper words, the number of cold page is 
>>total of resident cold pages
>>and non-resident pages. It's the seem number of non-resident cold pages 
>>can not beyond M at all!
>>    
>>
>
>You are right. So the total number of pages (non-resident + resident)
>around the clock is no more than 2m 
>(m is the memory size in pages).
>
>  
>
>>   
>>    I also have more questions on CLOCK-Pro. but this question is most 
>>doublt for me.
>>
>>    
>>
>  I am happy to help. I also have the clock-pro simulator that
>almost exactly simulates what's described in the paper. Let me
>know if you want it.
>
>   Song Jiang
>
>  
>
>>liyu
>>
>>   
>>
>>
>>
>>   
>>   
>>
>>--
>>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>the body to majordomo@kvack.org.  For more info on Linux MM,
>>see: http://www.linux-mm.org/ .
>>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>    
>>
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>
>  
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
