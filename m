Message-ID: <411813F0.9020602@us.ibm.com>
Date: Mon, 09 Aug 2004 17:16:48 -0700
From: Janet Morgan <janetmor@us.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.6.8-rc3-mm2:  Debug: sleeping function called from invalid
 context at mm/mempool.c:197
References: <B179AE41C1147041AA1121F44614F0B0DD03A6@AVEXCH02.qlogic.org>
In-Reply-To: <B179AE41C1147041AA1121F44614F0B0DD03A6@AVEXCH02.qlogic.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Vasquez <andrew.vasquez@qlogic.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Vasquez wrote:

>On Monday, August 09, 2004 6:42 AM, linux-kernel-owner@vger.kernel.org
>wrote: 
>  
>
>>I see the msg below while running on 2.6.8-rc3-mm2, but not
>>on the plain
>>rc3 tree;
>>ditto for rc1-mm1 vs rc1, which is as far back as I've gone so far.
>>
>>    
>>
>
>This allocation should be done with GFP_ATOMIC flags.  The attached 
>patch should apply cleanly to any recent kernel
>
>  
>

and seems to work fine.

Thanks,
-Janet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
