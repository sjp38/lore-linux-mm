Date: Sun, 10 Jun 2001 07:54:30 +0200 (CEST)
From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: Please test: workaround to help swapoff behaviour
In-Reply-To: <OF2FF3269C.90D4688C-ON85256A66.006DEAFA@pok.ibm.com>
Message-ID: <Pine.LNX.4.33.0106100752360.1004-100000@uplift.swm.pp.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jun 2001, Bulent Abali wrote:

> to find the swap cache page for a given swap entry." And he posted a
> patch http://mail.nl.linux.org/linux-mm/2001-03/msg00224.html
> His patch is in the Redhat 7.1 kernel 2.4.2-2 and not in 2.4.5.
>
> But in any case I believe the patch will not work as expected.

I second this. I have followed the discussion and I tried to swapoff a
vanilla redhat 7.1 machine with vanilla redhat kernel (celeron 500 with
IDE disks) with approx 100 megs in the swap and it took over a minute with
swapoff using 100% cpu.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
