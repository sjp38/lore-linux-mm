Message-ID: <413D0167.30202@sgi.com>
Date: Mon, 06 Sep 2004 19:31:35 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
References: <413CB661.6030303@sgi.com> <20040906131027.227b99ac.akpm@osdl.org> <413CD4FF.8070408@sgi.com> <20040906223724.GH3106@holomorphy.com> <413CF809.3010908@cyberone.com.au>
In-Reply-To: <413CF809.3010908@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, kernel@kolivas.org
List-ID: <linux-mm.kvack.org>


Nick Piggin wrote:

> 
>>
>> On Mon, Sep 06, 2004 at 04:22:07PM -0500, Ray Bryant wrote:
>>
>>> On a separate issue, the response to my proposal for a mempolicy to 
>>> control
>>> allocation of page cache pages has been <ahem> underwhelming.
>>> (See: http://marc.theaimsgroup.com/?l=linux-mm&m=109416852113561&w=2
>>> and  http://marc.theaimsgroup.com/?l=linux-mm&m=109416852416997&w=2 )
>>> I wonder if this is because I just posted it to linux-mm or its not 
>>> fleshed out enough yet to be interesting?
>>>
>>
>> It was very noncontroversial. Since it's apparently useful to someone
>> and generally low-impact it should probably be merged.
>>
>>
> 
> Yeah, I couldn't see any reason to not go ahead with it, which is why I
> didn't say anything :)
> 
> 

Cool.  I'll go ahead and finish it and make it something useful then.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
