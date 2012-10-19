Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id AFFA86B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 08:31:40 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so350452iak.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 05:31:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210181544590.1439@chino.kir.corp.google.com>
References: <1350600107-4558-1-git-send-email-elezegarcia@gmail.com>
	<alpine.DEB.2.00.1210181544590.1439@chino.kir.corp.google.com>
Date: Fri, 19 Oct 2012 09:31:39 -0300
Message-ID: <CALF0-+VZ429FETTByhKQOi-FYnCHvUGTWX6eL0Zp2NSgD1LbbQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/slob: Drop usage of page->private for storing
 page-sized allocations
From: Ezequiel Garcia <elezegarcia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Thu, Oct 18, 2012 at 7:46 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 18 Oct 2012, Ezequiel Garcia wrote:
>
>> This field was being used to store size allocation so it could be
>> retrieved by ksize(). However, it is a bad practice to not mark a page
>> as a slab page and then use fields for special purposes.
>> There is no need to store the allocated size and
>> ksize() can simply return PAGE_SIZE << compound_order(page).
>>
>> Cc: Pekka Penberg <penberg@kernel.org>
>
> Is Pekka Penberg the long distant cousin of Pekka Enberg? :)  You should
> probably cc the author of slob, Matt Mackall <mpm@selenic.com>, on slob
> patches.
>

Ouch! ;-)

I found another typo so I'll just re-send the whole patchset.

Thanks for the review!

    Ezequiel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
