Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id D421A6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:35:18 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so577506wmd.0
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 21:35:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j25sor347886wme.32.2017.12.18.21.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Dec 2017 21:35:17 -0800 (PST)
Subject: Re: [PATCH v5] mmap.2: MAP_FIXED updated documentation
References: <20171212002331.6838-1-jhubbard@nvidia.com>
 <3a07ef4d-7435-7b8d-d5c7-3bce80042577@gmail.com>
 <fb49f293-2048-e64f-51da-ff039929c7ac@nvidia.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <fb834f23-bbae-ea1b-1a55-a20e1cc88c0f@gmail.com>
Date: Tue, 19 Dec 2017 06:35:12 +0100
MIME-Version: 1.0
In-Reply-To: <fb49f293-2048-e64f-51da-ff039929c7ac@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: mtk.manpages@gmail.com, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@suse.com>, Pavel Machek <pavel@ucw.cz>

Hi John,

On 12/18/2017 10:27 PM, John Hubbard wrote:
> On 12/18/2017 11:15 AM, Michael Kerrisk (man-pages) wrote:
>> On 12/12/2017 01:23 AM, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
>>>
>>>     -- Expand the documentation to discuss the hazards in
>>>        enough detail to allow avoiding them.
>>>
>>>     -- Mention the upcoming MAP_FIXED_SAFE flag.
>>>
>>>     -- Enhance the alignment requirement slightly.
>>>
>>> CC: Michael Ellerman <mpe@ellerman.id.au>
>>> CC: Jann Horn <jannh@google.com>
>>> CC: Matthew Wilcox <willy@infradead.org>
>>> CC: Michal Hocko <mhocko@kernel.org>
>>> CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> CC: Cyril Hrubis <chrubis@suse.cz>
>>> CC: Michal Hocko <mhocko@suse.com>
>>> CC: Pavel Machek <pavel@ucw.cz>
>>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>>
>> John,
>>
>> Thanks for the patch. I think you win the prize for the 
>> most iterations ever on a man-pages patch! (And Michal,
>> thanks for helping out.) I've applied your patch, made 
>> some minor tweaks, and removed the mention of 
>> MAP_FIXED_SAFE, since I don't like to document stuff
>> that hasn't yet been merged. (I only later noticed the
>> fuss about the naming...)
>>
> 
> Hi Michael,
> 
> The final result looks nice, thanks for all the editing fixes.
> 
> One last thing: reading through this, I think it might need a wording
> fix (this is my fault), in order to avoid implying that brk() or
> malloc() use dlopen().
> 
> Something approximately like this:
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 79681b31e..1c0bd80de 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -250,8 +250,9 @@ suffice.
>  The
>  .BR dlopen (3)
>  call will map the library into the process's address space.
> -Furthermore, almost any library call may be implemented using this technique.
> -Examples include
> +Furthermore, almost any library call may be implemented in a way that
> +adds memory mappings to the address space, either with this technique,
> +or by simply allocating memory. Examples include
>  .BR brk (2),
>  .BR malloc (3),
>  .BR pthread_create (3),
> 
> 
> ...or does the current version seem OK to other people?

Thanks. Looks good to me. Applied.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
