Message-ID: <3B0F3B8D.E399FB82@uow.edu.au>
Date: Sat, 26 May 2001 15:13:49 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: Running out of vmalloc space
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com> <3B0AF30D.8D25806A@fc.hp.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Pinedo wrote:
>
>     if (size + addr < (unsigned long) tmp->addr)
>           break;
> 
> should be:
> 
>     if (size + addr <= (unsigned long) tmp->addr)
>           break;
> 
> Making this change seems to fix my problem. :-)

For the record - I sent this change on to Linus and
he applied it, incorrectly attributed to myself :(
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
