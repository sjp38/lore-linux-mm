Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EF8526B0071
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 15:37:58 -0400 (EDT)
Received: by fxm17 with SMTP id 17so881515fxm.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 12:37:57 -0700 (PDT)
Message-ID: <4C2B9D43.4070504@colorfullife.com>
Date: Wed, 30 Jun 2010 21:38:43 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [S+Q 01/16] [PATCH] ipc/sem.c: Bugfix for semop() not reporting
 successful operation
References: <20100625212026.810557229@quilx.com> <20100625212101.622422748@quilx.com> <AANLkTinmvRtH24uflD9e7MknaW6tgMSnN75vVgaj0IM6@mail.gmail.com> <alpine.DEB.2.00.1006291042100.16135@router.home> <20100629120857.00f4b42d.akpm@linux-foundation.org>
In-Reply-To: <20100629120857.00f4b42d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On 06/29/2010 09:08 PM, Andrew Morton wrote:
> On Tue, 29 Jun 2010 10:42:42 -0500 (CDT)
> Christoph Lameter<cl@linux-foundation.org>  wrote:
>
>    
>> This is a patch from Manfred. Required to make 2.6.35-rc3 work.
>>
>>      
> My current version of the patch is below.
>
> I believe that Luca has still seen problems with this patch applied so
> its current status is "stuck, awaiting developments".
>
> Is that a correct determination?
>    

I would propose that you forward a patch to Linus - either the one you 
have in your tree or the v2 that I've just posted.
With stock 2.6.35-rc3, my semtimedop() stress tests produces an oops or 
an invalid return value (i.e.:semtimedop() returns with "1") within a 
fraction of a second.

With either of the patches applied, my test apps show the expected behavior.

--
     Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
