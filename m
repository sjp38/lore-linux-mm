Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BE2E06B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 19:43:36 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id d42so2883823qca.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:43:35 -0800 (PST)
Message-ID: <51241C32.3050500@gmail.com>
Date: Wed, 20 Feb 2013 08:43:30 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: Should a swapped out page be deleted from swap cache?
References: <CAFNq8R4UYvygk8+X+NZgyGjgU5vBsEv1UM6MiUxah6iW8=0HrQ@mail.gmail.com> <alpine.LNX.2.00.1302180939200.2246@eggly.anvils> <5122C9B3.10306@gmail.com> <alpine.LNX.2.00.1302191056390.2248@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302191056390.2248@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Li Haifeng <omycle@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/20/2013 03:06 AM, Hugh Dickins wrote:
> On Tue, 19 Feb 2013, Will Huck wrote:
>> Another question:
> I don't see the connection to deleting a swapped out page from swap cache.
>
>> Why kernel memory mapping use direct mapping instead of kmalloc/vmalloc which
>> will setup mapping on demand?
> I may misunderstand you, and "kernel memory mapping".
>
> kmalloc does not set up a mapping, it uses the direct mapping already set up.
>
> It would be circular if the basic page allocation primitives used kmalloc,
> since kmalloc relies on the basic page allocation primitives.
>
> vmalloc is less efficient than using the direct mapping (repeated setup
> and teardown, no use of hugepages), but necessary when you want a larger

Is there tlb flush in setup and teardown process? and they also expensive?

> virtual array than you're likely to find from the buddy allocator.
>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
