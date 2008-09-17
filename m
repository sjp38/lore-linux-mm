Message-ID: <48D17AEC.3070804@goop.org>
Date: Wed, 17 Sep 2008 14:47:24 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Populating multiple ptes at fault time
References: <48D142B2.3040607@goop.org> <20080917142805.41e2b07e@bree.surriel.com>
In-Reply-To: <20080917142805.41e2b07e@bree.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Wed, 17 Sep 2008 10:47:30 -0700
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>
>   
>> Minor faults are easier; if the page already exists in memory, we should
>> just create mappings to it.  If neighbouring pages are also already
>> present, then we can can cheaply create mappings for them too.
>>     
>
> This is especially true for mmaped files, where we do not have to
> allocate anything to create the mapping.
>   

Yes, that was the case I particularly had in mind.

> Populating multiple PTEs at a time is questionable for anonymous
> memory, where we'd have to allocate extra pages.
>   

It might be worthwhile if the memory access pattern to anonymous memory
is linear.  I agree that speculatively allocating pages on a random
access region would be a bad idea.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
