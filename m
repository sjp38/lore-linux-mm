From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200008171936.MAA31128@google.engr.sgi.com>
Subject: Re: pte_pagenr/MAP_NR deleted in pre6
Date: Thu, 17 Aug 2000 12:36:51 -0700 (PDT)
In-Reply-To: <200008171920.MAA23931@pizda.ninka.net> from "David S. Miller" at Aug 17, 2000 12:20:50 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, roman@augan.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, rmk@arm.linux.org.uk, nico@cam.org, davidm@hpl.hp.com
List-ID: <linux-mm.kvack.org>

> 
>    Date: Thu, 17 Aug 2000 20:19:59 +0100 (BST)
>    From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
>    > My only two gripes about paddr_t is that long long is not only
>    > expensive but has been also known to be buggy on 32-bit platforms.
> 
>    Except for the x86 36bit abortion do we need a long long paddr_t on any
>    32bit platform ?
> 
> Sparc32, mips32...
>

Not for Indys on mips32. Is there a mips32 port on another machine
(currently in Linux, or port ongoing) that requires this?

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
