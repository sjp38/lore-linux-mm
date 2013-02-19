Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 30F706B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 14:06:57 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id xb4so2399876pbc.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 11:06:56 -0800 (PST)
Date: Tue, 19 Feb 2013 11:06:15 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Should a swapped out page be deleted from swap cache?
In-Reply-To: <5122C9B3.10306@gmail.com>
Message-ID: <alpine.LNX.2.00.1302191056390.2248@eggly.anvils>
References: <CAFNq8R4UYvygk8+X+NZgyGjgU5vBsEv1UM6MiUxah6iW8=0HrQ@mail.gmail.com> <alpine.LNX.2.00.1302180939200.2246@eggly.anvils> <5122C9B3.10306@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Li Haifeng <omycle@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 19 Feb 2013, Will Huck wrote:
> 
> Another question:

I don't see the connection to deleting a swapped out page from swap cache.

> 
> Why kernel memory mapping use direct mapping instead of kmalloc/vmalloc which
> will setup mapping on demand?

I may misunderstand you, and "kernel memory mapping".

kmalloc does not set up a mapping, it uses the direct mapping already set up.

It would be circular if the basic page allocation primitives used kmalloc,
since kmalloc relies on the basic page allocation primitives.

vmalloc is less efficient than using the direct mapping (repeated setup
and teardown, no use of hugepages), but necessary when you want a larger
virtual array than you're likely to find from the buddy allocator.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
