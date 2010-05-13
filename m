Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D95776B0202
	for <linux-mm@kvack.org>; Thu, 13 May 2010 05:03:15 -0400 (EDT)
Received: by pva4 with SMTP id 4so443155pva.14
        for <linux-mm@kvack.org>; Thu, 13 May 2010 02:03:12 -0700 (PDT)
Message-ID: <4BEBBF7E.30500@vflare.org>
Date: Thu, 13 May 2010 14:29:42 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH] Cleanup migrate case in try_to_unmap_one
References: <20100513144336.216D.A69D9226@jp.fujitsu.com> <4BEBA70C.9050404@vflare.org> <20100513163441.2176.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100513163441.2176.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 05/13/2010 01:36 PM, KOSAKI Motohiro wrote:
>> On 05/13/2010 11:34 AM, KOSAKI Motohiro wrote:
>>>> Remove duplicate handling of TTU_MIGRATE case for
>>>> anonymous and filesystem pages.
>>>>
>>>> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
>>>
>>> This patch change swap cache case. I think this is not intentional.
>>
>> IIUC, we never call this function with TTU_MIGRATE for swap cache pages.
>> So, the behavior after this patch remains unchanged.
> 
> Why?
> 
> 


Kindly ignore. Looks like I misunderstood this part.
Sorry for the trouble.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
