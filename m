From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14306.24964.242982.672946@dukat.scot.redhat.com>
Date: Fri, 17 Sep 1999 16:43:00 +0100 (BST)
Subject: Re: about the MTRR (memory type range reg)
In-Reply-To: <Pine.SOL.4.10.9909171005120.2394-100000@elf>
References: <Pine.SOL.4.10.9909171005120.2394-100000@elf>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gilles Pokam <pokam@cs.tu-berlin.de>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 17 Sep 1999 10:12:26 +0200 (MET DST), Gilles Pokam
<pokam@cs.tu-berlin.de> said:

> I want to change the memory type of a particular memory region. I know
> that the MTRR (Memory Type Range Register) is responsible of that in most
> pentium processor-based systems. My question is to know if there is an API
> in Linux to access this register (if yes, do you have example ) ?

Yes: /proc/mtrr.  Read linux/Documentation/mtrr.txt

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
