Subject: Re: -__PAGE_OFFSET
References: <20010920065444.10415.qmail@mailweb13.rediffmail.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 20 Sep 2001 02:54:10 -0600
In-Reply-To: <20010920065444.10415.qmail@mailweb13.rediffmail.com>
Message-ID: <m1wv2udyz1.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: amey d inamdar <iamey@rediffmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"amey d inamdar" <iamey@rediffmail.com> writes:

> Hello everybody,
>      While running through source of 2.4 kernel, in head.S, I found the 
> line
> 86 :   movl $pg0-__PAGE_OFFSET,%edi
> 
>     I am not getting, at this point there is no virtual address & $pg0 
> itself contains physical address of first page table, then why to 
> subtract 3GB from the physical address?

The linker doesn't know the page tables haven't been setup yet.
Look at the addresses in System.map.

>       Thanx in anticipation.

Welcome.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
