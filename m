Subject: Re: Please test: workaround to help swapoff behaviour
Message-ID: <OF215A9F3A.3CFF9D00-ON85256A65.007FE32C@watson.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Fri, 8 Jun 2001 19:53:35 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, "Eric W. Biederman" <ebiederm@xmission.com>, Derek Glidden <dglidden@illusionary.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> I looked at try_to_unuse in swapfile.c.  I believe that the algorithm is
>> broken.
>> For each and every swap entry it is walking the entire process list
>> (for_each_task(p)).  It is also grabbing a whole bunch of locks
>> for each swap entry.  It might be worthwhile processing swap entries in
>> batches instead of one entry at a time.
>>
>> In any case, I think having this patch is worthwhile as a quick and
dirty
>> remedy.
>
>Bulent,
>
>Could you please check if 2.4.6-pre2+the schedule patch has better
>swapoff behaviour for you?

No problem.  I will check it tomorrow. I don't think it can be any worse
than it is now.  The patch looks correct in principle.
I believe it should go in to 2.4.6.  But I will test it.

On small machines people don't notice it, but otherwise if you have few
GB of memory it really hurts.  Shutdowns take forever since swapoff takes
forever.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
