Message-ID: <380EA6C1.DA32BC3A@263.net>
Date: Thu, 21 Oct 1999 13:38:09 +0800
From: Wang Yong <wung_y@263.net>
Reply-To: wung_y@263.net
MIME-Version: 1.0
Subject: Re: Paging out sleepy processes?
References: <380D7C24.AA10E463@mandrakesoft.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: mail list linux-mm mail list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

why do u want to force it out. in my opinion, mm need to swap some process
out when the amount of physical
memory is under some limit.
MM will force it out if MM choose this process to swap out.if MM not choose
it, that's to say free memory is
enough or some other processes should be swapped out.

Jeff Garzik wrote:

> I have a simple app that I run locally that allocates and randomly
> dirties a lot of memory all at once, with the intention of forcing Linux
> to swap out processes.
>
> How possible/reasonable would it be to add a feature which will swap out
> processes that have been asleep for a long time?
>
> IMHO this behavior would default to off, but can be enabled by
> specifying the age at which the system should attempt to swap out
> processes:
>
>         # tell kernel to swap out processes which have been asleep
>         # longer than N seconds
>         echo 7200 > /proc/sys/vm/min_sleepy_swap
>
> Is there a way to do this already?
>
> Regards,
>
>         Jeff
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
