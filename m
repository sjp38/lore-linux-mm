Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 871796B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 10:44:40 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so204603rvb.26
        for <linux-mm@kvack.org>; Thu, 13 Aug 2009 07:44:44 -0700 (PDT)
Message-ID: <4A8426CE.5090605@vflare.org>
Date: Thu, 13 Aug 2009 20:14:30 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH] swap: send callback when swap slot is freed
References: <200908122007.43522.ngupta@vflare.org>	 <Pine.LNX.4.64.0908122312380.25501@sister.anvils>	 <4A837AAF.4050103@vflare.org> <1250146380.10001.47.camel@twins>
In-Reply-To: <1250146380.10001.47.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(resending in plain text)

On 08/13/2009 12:23 PM, Peter Zijlstra wrote:
> On Thu, 2009-08-13 at 08:00 +0530, Nitin Gupta wrote:
>>> I don't share Peter's view that it should be using a more general
>>> notifier interface (but I certainly agree with his EXPORT_SYMBOL_GPL).
>> Considering that the callback is made under swap_lock, we should not
>> have an array of callbacks to do. But what if this callback finds other
>> users too? I think we should leave it in its current state till it finds
>> more users and probably add BUG() to make sure callback is not already set.
>>
>> I will make it EXPORT_SYMBOL_GPL.
>
> If its such a tightly coupled system, then why is compcache a module?
>

Keeping everything as separate kernel modules has been the goal of this 
project. However, this callback is the only thing which I could not do 
without this small patching.

Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
