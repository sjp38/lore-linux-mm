Subject: Re: Allocation of kernel memory >128K
References: <Pine.LNX.4.21.0112111531110.5038-100000@mailhost.tifr.res.in>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 11 Dec 2001 03:41:01 -0700
In-Reply-To: <Pine.LNX.4.21.0112111531110.5038-100000@mailhost.tifr.res.in>
Message-ID: <m1k7vuujia.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Amit S. Jain" <amitjain@tifr.res.in> writes:

> I have been working on a module in which I copy large amount of data fromn
> the user to the kernel area.To do so I allocate using either kmaaloc or
> vmalloc or  get_free_pages()large amount of memory(in the range of
> MBytes) in the kernel space.However this attempt is not successful.One ofmy 
> colleagues informed me that in the kernel space it is safe not to allocate
> large amount of memory at one time,should be kept upto 30K...is he
> right....could you throw more light on this issue.

large amounts of memory are o.k. 
large amounts of continuous memory is generally a bad thing.

Allocating everything with multiple calls to get_free_page() should
get the job done.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
