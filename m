Message-ID: <432F9DFC.9000702@ccoss.com.cn>
Date: Tue, 20 Sep 2005 13:28:28 +0800
From: liyu <liyu@ccoss.com.cn>
MIME-Version: 1.0
Subject: Re: [Question] How to understand Clock-Pro algorithm?
References: <432F7DD5.6050204@ccoss.com.cn>	 <1127188898.3130.52.camel@moon.c3.lanl.gov> <432F97E1.4080805@ccoss.com.cn> <1127193398.3130.131.camel@moon.c3.lanl.gov>
In-Reply-To: <1127193398.3130.131.camel@moon.c3.lanl.gov>
Content-Type: text/plain; charset=gb18030; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Song Jiang <sjiang@lanl.gov>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, All.
   
    In my words, pages in memory is either resident or non-resident.
In linux internal, mapped or unmapped.
   
    So number of non-resident pages is alway less than total number
of pages in memory.

    Is your pages physics pages? or, it is Logical pages?   However,
I think both is same here.

    Waitting for your answer.
   
    Thanks.


                                                 liyu


Song Jiang Wrote:

>On Mon, 2005-09-19 at 23:02, liyu wrote:
>
>  
>
>>    Let's assume Mn is the total number of non-resident pages in follow 
>>words.
>>
>>    Nod, 'M=Mh+Mc' and 'Mc+Mn' < 2M are always true.
>>
>>    Have this implied that Mn is alway less than M? I think so.
>>    
>>
>    Yes.
>
>  
>
>>    but if "Once the number exceeds M the memory size in number of pages,
>>we terminted the test period of the cold page pointed to by HAND-test."
>>
>>    If Mn is alway less than M, when we move to HAND-test?
>>    
>>
>
>The algorithm tries to ensure that Mn <= M holds. 
>Once Mn == M+1 is detected, run HAND-test to bring it
>back to Mn == M. That is, only during the transition period, 
>Mn <= M might not hold, and we make a correction quickly.
>
>So there is no contradiction here.
>   Song
>
>  
>
>
>
>
>
>  
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
