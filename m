Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EF35C6B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 18:13:49 -0400 (EDT)
Message-ID: <4BFC4B9D.1080902@yahoo.es>
Date: Wed, 26 May 2010 00:13:49 +0200
From: Albert Herranz <albert_herranz@yahoo.es>
MIME-Version: 1.0
Subject: Re: [Bulk] Re: page_mkwrite vs pte dirty race in fb_defio
References: <20100525160149.GE20853@laptop> <4BFC1657.5000707@yahoo.es> <20100525184700.GJ20853@laptop>
In-Reply-To: <20100525184700.GJ20853@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: aya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 05/25/2010 08:47 PM, Nick Piggin wrote:
>>> I hope that should provide a more elegant solution to your problem. I
>>> would really like you to take a look at that, because we already have
>>> filesystem code (NFS) relying on it, and more code we have relying on
>>> this synchronization, the more chance we would find a subtle problem
>>> with it (also it should be just nicer).
>>
>> So if I undestand it correctly, using the "new" calling convention I should just lock the page on fb_deferred_io_mkwrite() and return VM_FAULT_LOCKED to fix the described race for fb_defio.
> 
> As far as I can see from quick reading of the fb_defio code, yes
> that should solve it (provided you lock the page inside the mutex,
> of course).
> 

Ok, thanks. I'm posting a new version as RFT.

Cheers,
Albert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
